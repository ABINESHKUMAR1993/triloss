import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trilo_app/constants/constants.dart';
import './audio_call_screen.dart';
import './profile_screen.dart';

class AllUserScreen extends StatefulWidget {
  const AllUserScreen({super.key});

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  bool _isLoading = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _getAllUsers();
  }

  Future<void> _getAllUsers() async {
    final url = Uri.parse('$baseUrl/get_all_users');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() => _isLoading = true);

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

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          _users = data['data']['users'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error fetching users: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToProfile(Map<String, dynamic> user) {
    Get.to(() => ProfileScreen(userId: user['user_id'].toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              _users
                                  .map(
                                    (user) => ProfileCard(
                                      user: user,
                                      onTap: () => _navigateToProfile(user),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: CarouselSlider(
                items:
                    [
                          'assets/images/png/carousel_slider.png',
                          'assets/images/png/carousel_slider.png',
                          'assets/images/png/carousel_slider.png',
                        ]
                        .map((item) => Image.asset(item, fit: BoxFit.cover))
                        .toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const ProfileCard({super.key, required this.user, required this.onTap});

  void _navigateToCall(BuildContext context) {
    Get.to(
      () => AudioCallScreen(
        userName: user['name'] ?? 'No Name',
        profileImageUrl: user['profile_image_url'] ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 200,
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.pink[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  backgroundImage:
                      user['profile_image_url']?.isNotEmpty == true
                          ? NetworkImage(user['profile_image_url'])
                          : const AssetImage('assets/images/png/user.png')
                              as ImageProvider,
                  radius: 40,
                ),
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: user['is_online'] ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  width: 12,
                  height: 18,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user['language'] ?? 'Unknown',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 8),
            Text(
              user['name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _navigateToCall(context),
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('Join', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
