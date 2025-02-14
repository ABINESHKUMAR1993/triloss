import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool _isLoading = false;
  late String baseUrl; // Define your base URL
  late String apiKey; // Define your API key

  @override
  void initState() {
    super.initState();
    _userTransaction();
  }

  Future<void> _userTransaction() async {
    final url = Uri.parse('$baseUrl/user_transaction'); // API endpoint

    // Get the saved auth token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey, // Your API key
          "Authorization":
              "Bearer $authToken", // Bearer token for authentication
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the status is "success"
        if (responseData['status'] == 'success') {
          final transaction = responseData['data']['transaction'];
          final subscription = responseData['data']['subscription'];

          // Update the UI or perform any logic with the transaction and subscription data
          print('Transaction Successful: ${transaction['transaction_id']}');
          print('Subscription Plan: ${subscription['plan_name']}');

          // You can now update the UI to reflect the successful subscription
        } else {
          // Handle API response error (if status is not success)
          print('API Error: ${responseData['message']}');
        }
      } else {
        // Handle the error if the status code is not 200
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Catch any network or parsing errors
      print('Request failed: $error');
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Transaction Card UI
            _isLoading
                ? CircularProgressIndicator() // Show loading indicator while the API request is in progress
                : _buildTransactionCard(
                  title: 'Basic Pack:',
                  minutes: '50 minutes',
                  price: '\$5.99',
                  validity: 'Valid for 30 days',
                  date: '21/01/2024',
                  status: 'Paid',
                  statusColor: Colors.green,
                ),
            const SizedBox(height: 24),
            const Text(
              'Last week',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Transaction Card UI (additional data)
            _buildTransactionCard(
              title: 'Popular Pack:',
              minutes: '80 minutes',
              price: '\$10.99',
              validity: 'Valid for 30 days',
              date: '21/01/2024',
              status: 'Paid',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTransactionCard(
              title: 'Unlimited Pack:',
              minutes: 'Unlimited minutes',
              price: '\$29.99/month',
              validity: '',
              date: '21/01/2024',
              status: 'Failed',
              statusColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String minutes,
    required String price,
    required String validity,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(minutes, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 14)),
          if (validity.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(validity, style: const TextStyle(fontSize: 14)),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
