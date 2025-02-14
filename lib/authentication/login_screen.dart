import 'dart:developer' as developer;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/views/screens/home_screen.dart';
import 'package:trilo_app/views/screens/otp_screen.dart';
import 'package:trilo_app/views/widgets/app_button.dart';
import 'package:trilo_app/views/widgets/textfield_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _isChecked = false;
  final TextEditingController _controller = TextEditingController();
  String _selectedCountryCode = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCountryCode = prefs.getString('countryCode') ?? '+91';
      _isChecked = prefs.getBool('termsAccepted') ?? false;
    });
  }

  _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('countryCode', _selectedCountryCode);
    prefs.setBool('termsAccepted', _isChecked);
  }

  Future<void> login() async {
    final url = Uri.parse('$baseUrl/login');
    setState(() {
      _isLoading = true;
    });

    try {
      String phoneNumber = _controller.text.replaceAll(RegExp(r'\D'), '');

      developer.log("Phone number after cleanup: $phoneNumber");

      if (phoneNumber.length != 10) {
        developer.log("Invalid phone number length: $phoneNumber");
        Get.snackbar("Error", "Please enter a valid 10-digit phone number.");
        return;
      }

      if (!_isChecked) {
        developer.log("User did not accept terms and conditions.");
        Get.snackbar("Error", "Please accept terms and conditions");
        return;
      }

      final Map<String, dynamic> body = {
        'phone_number': phoneNumber,
        'country_code': _selectedCountryCode,
        'terms_accepted': _isChecked,
      };

      developer.log("Request body: ${json.encode(body)}");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
        },
        body: json.encode(body),
      );

      developer.log("Response status code: ${response.statusCode}");
      developer.log("Response body: ${response.body}");

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (data['data']['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['data']['token']);
          developer.log("Auth token saved successfully.");
        }

        Get.snackbar(
          "Success",
          "OTP sent successfully to ${_selectedCountryCode + phoneNumber}",
        );

        Get.to(
          () => OTPVerificationScreen(
            phoneNumber: phoneNumber,
            countryCode: _selectedCountryCode,
          ),
        );
      } else {
        developer.log(
          "Error in response: ${data['message'] ?? 'Failed to send OTP'}",
        );
        Get.snackbar("Error", data['message'] ?? "Failed to send OTP");
      }
    } catch (error) {
      developer.log("Network error: $error");
      Get.snackbar("Error", "Network error: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrapping content in a scroll view
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 380),
                Center(
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _controller,
                  hintText: 'Enter Phone Number',
                  prefixIcon: CountryCodePicker(
                    onChanged: (code) {
                      setState(() {
                        _selectedCountryCode = code.dialCode ?? '+91';
                      });
                      _savePreferences();
                    },
                    initialSelection: _selectedCountryCode.replaceAll('+', ''),
                    showCountryOnly: true,
                    showFlag: true,
                    showFlagDialog: true,
                    alignLeft: false,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                AppMainButton(
                  onTap: () {
                    if (_controller.text.isNotEmpty) {
                      login();
                    } else {
                      Get.snackbar("Error", "Please enter your phone number");
                    }
                  },
                  text: 'Get OTP',
                  isDefault: true,
                  isLoading: RxBool(_isLoading),
                ),
                const SizedBox(height: 16),
                AppMainButton(
                  onTap: () {
                    Get.to(() => HomeScreen());
                  },
                  text: 'Guest Login',
                  isDefault: true,
                  isLoading: RxBool(false),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.white,
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1),
                            side: BorderSide(color: Colors.white),
                          ),
                          checkColor: WidgetStateProperty.all(Colors.red),
                          fillColor: WidgetStateProperty.all(Colors.white),
                        ),
                      ),
                      child: Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                          _savePreferences();
                        },
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'By signing up you\'re accepting to ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: Colors.white),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      developer.log("Terms of Service tapped");
                                    },
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Colors.white),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      developer.log("Privacy Policy tapped");
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
