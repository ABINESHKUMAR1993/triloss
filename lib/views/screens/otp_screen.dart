import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/constants/main_colors.dart';
import 'package:trilo_app/views/widgets/button.dart';
import 'set_profile_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  bool _isLoading = false;

  void _onNumberChanged(String value, int index) {
    if (value.isNotEmpty && index < 4) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  Future<void> login_verify() async {
    setState(() {
      _isLoading = true;
    });

    final otpCode = _controllers.map((controller) => controller.text).join('');

    if (otpCode.length != 5) {
      Get.snackbar("Error", "Please enter a valid 5-digit OTP");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/login_verify');
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({
          "otp": otpCode,
          "phone_number": widget.phoneNumber,
          "country_code": widget.countryCode,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody["status"] == "success") {
        // Store the new auth token if provided
        if (responseBody['data']['token'] != null) {
          await prefs.setString('auth_token', responseBody['data']['token']);
        }

        Get.snackbar("Success", "OTP verified successfully");
        Get.to(() => SetProfileScreen());
      } else {
        Get.snackbar(
          "Error",
          responseBody['message'] ?? "OTP verification failed",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: const Text(
                  'We have sent you a 5 digit code. Please enter ',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              Center(
                child: const Text(
                  'below to verify your Number.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.phoneNumber.isNotEmpty ? widget.phoneNumber : '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: cRed,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => SizedBox(
                    width: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        maxLength: 1,
                        onChanged: (value) => _onNumberChanged(value, index),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Button(
                onTap: login_verify, // Trigger the login_verify function
                text: _isLoading ? 'Verifying...' : 'Verify',
                isDefault: true,
                isLoading: RxBool(_isLoading),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t Receive Code?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      login_verify();
                    },
                    child: const Text(
                      'Get a New One',
                      style: TextStyle(
                        color: cRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
