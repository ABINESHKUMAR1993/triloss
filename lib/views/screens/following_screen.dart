import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/views/screens/profile_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  bool _isLoading = false;
  List<dynamic> _followedUsers = [];

  @override
  void initState() {
    super.initState();
    _getFollowedUsers();
  }

  Future<void> _getFollowedUsers() async {
    final url = Uri.parse('$baseUrl/get_followed_users');
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
            _followedUsers = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Failed to load followed users: ${data['message']}');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(
          'Failed to fetch data. Error code: ${response.statusCode}',
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Network error: $error');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    // painter: HeartPatternPainter(),
                  ),
                  ...profileAvatars(),
                ],
              ),
    );
  }

  List<Widget> profileAvatars() {
    final random = Random();
    return _followedUsers.map((profile) {
      final profileImage =
          profile['profile_image'] != null &&
                  profile['profile_image'].isNotEmpty
              ? '$imgUrl/${profile['profile_image']}'
              : 'assets/images/png/user.png';

      // Randomize positions
      double left =
          random.nextDouble() *
          (MediaQuery.of(context).size.width -
              10); // 60 is the size of the avatar
      double top =
          random.nextDouble() *
          (MediaQuery.of(context).size.height -
              10); // 60 is the size of the avatar

      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: profile['user_id']),
              ),
            );
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/png/user.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                profile['name'] ?? 'Unknown',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
