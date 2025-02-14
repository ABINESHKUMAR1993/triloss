import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/constants/main_colors.dart';
import 'payment_screen.dart';

class TalkTimePage extends StatefulWidget {
  const TalkTimePage({super.key});

  @override
  State<TalkTimePage> createState() => _TalkTimePageState();
}

class _TalkTimePageState extends State<TalkTimePage> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> plans = [];
  int? selectedPlan;

  @override
  void initState() {
    super.initState();
    _showPlan();
  }

  Future<void> _showPlan() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        print('Debug: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final url = Uri.parse('$baseUrl/show_plan');
      print('Debug: Sending request to $url');

      final response = await http
          .get(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "x-api-key": apiKey,
              "Authorization": "Bearer $authToken",
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('Debug: Request timed out');
              throw Exception('Request timed out');
            },
          );

      print('Debug: Response status code: ${response.statusCode}');
      print('Debug: Response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (mounted) {
          setState(() {
            plans = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      } else {
        print('Debug: Failed to fetch plans - ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to fetch plans');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
      print('Debug: Error occurred: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load plans. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePlanSelection(int index) {
    if (index < 0 || index >= plans.length) return;

    setState(() {
      selectedPlan = index;
    });
  }

  void _navigateToPayment() {
    if (selectedPlan == null || selectedPlan! >= plans.length) return;

    final plan = plans[selectedPlan!];
    final talkTime = int.tryParse(plan['talk_time']?.toString() ?? '') ?? 0;
    final amount = int.tryParse(plan['amount']?.toString() ?? '') ?? 0;

    if (talkTime <= 0 || amount <= 0) {
      Get.snackbar(
        'Error',
        'Invalid plan details',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // Pass the selected plan data to the PaymentPage
    Get.to(() => PaymentScreen(talktime: talkTime, payableAmount: amount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TalkTime',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available TalkTime',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                '₹0',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Add TalkTime',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showPlan,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (plans.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No plans available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: plans.length,
                    itemBuilder: (context, index) => _buildPlanCard(index),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedPlan == null ? null : _navigateToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: cWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = plans[index];
    return InkWell(
      onTap: () => _handlePlanSelection(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPlan == index ? cPrimaryColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Get',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${plan['talk_time']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cPrimaryColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(6),
                ),
              ),
              child: Text(
                '₹${plan['amount']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
