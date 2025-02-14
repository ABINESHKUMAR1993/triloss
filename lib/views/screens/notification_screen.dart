import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/constants/main_colors.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  bool _isLoading = false;
  List<dynamic> _notifications = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    notification();
  }

  Future<void> notification() async {
    final url = Uri.parse('$baseUrl/notification');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    if (authToken.isEmpty) {
      setState(() {
        _errorMessage = 'Authorization token is missing.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Reset error message when fetching new data
    });

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response is in the correct format
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          setState(() {
            _notifications = data['data'] ?? [];
          });
        } else {
          setState(() {
            _errorMessage =
                'Failed to fetch notifications. Response format error.';
          });
          log('Error: Response format error. Data: $data');
        }
      } else {
        setState(() {
          _errorMessage =
              'API request failed with status code: ${response.statusCode}';
        });
        log(
          'Error: API request failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      log('Exception occurred: $e');
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
          icon: const Icon(Icons.arrow_back_ios, color: cPrimaryColor),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _notifications.isEmpty
              ? const Center(child: Text('No notifications available.'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._notifications.map((notification) {
                    return Column(
                      children: [
                        _buildNotificationCard(
                          title: notification['title'],
                          message: notification['description'],
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                ],
              ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
