import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/views/screens/all_user_screen.dart';
import 'package:trilo_app/views/screens/drawer_screen.dart';
import 'package:trilo_app/views/screens/following_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final List<Widget> _screens = [const AllUserScreen(), FollowingScreen()];

  String talktimeAmount = "0";
  bool _isLoading = false;
  String profileImage = '';
  String userName = '';
  bool isUserOnline = false; // User online status

  @override
  void initState() {
    super.initState();
    _getUserTalktimeAmount();
    _getProfile(); // Fetch profile data on init
  }

  // Function to get the user talktime amount
  Future<void> _getUserTalktimeAmount() async {
    final url = Uri.parse('$baseUrl/get_usertalktime_amount');
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
        if (data['status'] == 'success') {
          setState(() {
            talktimeAmount = data['data']['talktime_amount'].toString();
          });
        }
      } else {
        throw Exception('Failed to load talktime amount');
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to get the user profile data
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
        if (data['status'] == 'success') {
          setState(() {
            profileImage =
                data['data']['profile_image'] ??
                ''; // Handle null profile image
            userName = data['data']['name'];
            isUserOnline =
                data['data']['is_online'] ?? false; // Check if user is online
          });
        } else {
          throw Exception('Failed to load profile');
        }
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building HomeScreen with selectedTabIndex: $_selectedTabIndex");

    return Scaffold(
      backgroundColor: _selectedTabIndex == 1 ? Colors.blue : Colors.white,
      appBar: AppBar(
        backgroundColor: _selectedTabIndex == 1 ? Colors.blue : Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // Open the drawer using the builder context
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Display profile image from API response
            Stack(
              clipBehavior:
                  Clip.none, // To ensure that the status circle doesn't get clipped
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : const AssetImage('assets/images/png/user.png')
                              as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: isUserOnline ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    width: 12,
                    height: 10,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                      '$talktimeAmount',
                      style: const TextStyle(color: Colors.black),
                    ),
              ],
            ),
          ],
        ),
      ),
      // Add the Drawer here
      drawer: const DrawerScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _TabButton(
                  label: 'All',
                  isSelected: _selectedTabIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                      debugPrint("Tab changed to All");
                    });
                  },
                ),
                const SizedBox(width: 12),
                _TabButton(
                  label: 'Following',
                  isSelected: _selectedTabIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                      debugPrint("Tab changed to Following");
                    });
                  },
                ),
              ],
            ),
            Expanded(child: _screens[_selectedTabIndex]),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors
                      .pink // Set selected tab color to blue
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue,
          ), // Border color should also match
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? Colors
                        .white // Text color when selected
                    : Colors.black, // Text color when not selected
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
