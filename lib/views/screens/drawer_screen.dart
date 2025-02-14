import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/views/screens/edit_profile_screen.dart';
import 'package:trilo_app/views/screens/notification_screen.dart';
import 'package:trilo_app/views/screens/talk_time_screen.dart';
import 'package:trilo_app/views/screens/transaction_screen.dart';
import 'package:trilo_app/views/screens/user_settings_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    final url = Uri.parse('$baseUrl/get_profile');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
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

        // Check if the API response is successful and contains data
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            _profileData = data['data'];
          });
        } else {
          _showErrorSnackBar('Failed to load profile: ${data['message']}');
        }
      } else {
        _showErrorSnackBar('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 80.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image:
                              _profileData['profile_image'] != null &&
                                      _profileData['profile_image'] != 'null'
                                  ? NetworkImage(_profileData['profile_image'])
                                  : const AssetImage(
                                    'assets/images/png/user.png',
                                  ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const EditProfileScreen());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profileData['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profileData['dob'] ?? 'Not Available',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: ${_profileData['user_id'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          _buildMenuItem(
            image: Image.asset(
              'assets/images/png/call.png',
              width: 25,
              height: 25,
            ),
            title: "Buy Talktime",
            onTap: () {
              Get.to(() => TalkTimePage());
            },
            trailing: _buildCoinBadge(),
          ),
          _buildMenuItem(
            image: Image.asset(
              'assets/images/png/money.png',
              width: 25,
              height: 25,
            ),
            title: "Talktime Transactions",
            onTap: () {
              Get.to(() => TransactionScreen());
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications,
            title: "Notification",
            onTap: () {
              Get.to(() => NotificationPage());
            },
          ),

          _buildMenuItem(
            icon: Icons.settings,
            title: "User Settings",
            onTap: () {
              Get.to(() => UserSettingsPage());
            },
          ),
          _buildMenuItem(
            icon: Icons.exit_to_app,
            title: "Logout",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? title,
    Function? onTap,
    Widget? trailing,
    Image? image,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: InkWell(
        onTap: () {
          onTap?.call();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (image != null)
              image
            else if (icon != null)
              Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/png/walet.png', width: 20, height: 20),
          const SizedBox(width: 4),
          const Text(
            '₹ 0',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
