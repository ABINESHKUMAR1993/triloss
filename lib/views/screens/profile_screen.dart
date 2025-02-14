import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/views/screens/chat_screen.dart';
import 'package:trilo_app/views/screens/video_call_screen.dart';
import 'audio_call_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;
  bool _isFollowing = false;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _getOtherUserProfile();
  }

  Future<void> _getOtherUserProfile() async {
    final url = Uri.parse('$baseUrl/get_otheruser_profile/${widget.userId}');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      log("Fetching profile for user: ${widget.userId}");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
      );

      log("Response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _profileData = data['data'];
            _isLoading = false;
            _isFollowing = data['data']['is_following'] ?? false;
            imageUrl =
                _profileData?['profile_image'] != null
                    ? "$imgUrl/${_profileData?['profile_image']}"
                    : '';
            // Use default image logic if profile_image is null
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load user profile');
        }
      } else {
        throw Exception(
          'Failed to load user profile. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showError(_errorMessage!);
    }
  }

  Future<void> _userFollow() async {
    final url = Uri.parse('$baseUrl/user_follow'); // Ensure the URL is correct
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      log("Sending follow request for user: ${widget.userId}");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: json.encode({
          'folw_user_id': widget.userId,
        }), // Corrected field name
      );

      log("Response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          _isFollowing = true;
          _isLoading = false;
        });
        _showSuccess('You are now following the user.');
      } else if (response.statusCode == 404) {
        throw Exception('The requested resource could not be found.');
      } else {
        throw Exception(data['message'] ?? 'Failed to follow user');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _userUnfollow() async {
    final url = Uri.parse('$baseUrl/user_unfollow');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      log("Sending unfollow request for user: ${widget.userId}");
      log("URL: $url");
      log(
        "Headers: ${{"Accept": "application/json", "Content-Type": "application/json", "x-api-key": apiKey, "Authorization": "Bearer $authToken"}}",
      );
      log("Body: ${json.encode({'folw_user_id': widget.userId})}");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: json.encode({'folw_user_id': widget.userId}),
      );

      log("Response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          _isFollowing = false;
          _isLoading = false;
        });
        _showSuccess('You have unfollowed the user.');
      } else {
        throw Exception(data['message'] ?? 'Failed to unfollow user');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _checkMessagingPermission() async {
    if (!_isFollowing) {
      _showError('You need to follow this user to send a message.');
      return;
    }

    Get.to(
      ChatScreen(
        userName: _profileData?['name'] ?? 'No Name',
        receiverId: widget.userId,
        profileImageUrl: imageUrl, // Use the validated imageUrl
      ),
    );
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
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _getOtherUserProfile();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _profileData == null
              ? const Center(
                child: Text(
                  'User not found.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage(
                                          'assets/images/png/user.png',
                                        )
                                        as ImageProvider<Object>,
                            child:
                                imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profileData?['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _profileData?['language'] ?? 'Not available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  '${_profileData?['dob'] ?? 'Date of birth not available'}${_profileData?['gender'] != null ? ' | Gender: ${_profileData?['gender']}' : ''}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  _profileData?['country'] ?? 'Not available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildProfileContent(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? Colors.grey : Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
            foregroundColor: Colors.white,
          ),
          onPressed: _isFollowing ? _userUnfollow : _userFollow,
          child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
        ),
        const SizedBox(height: 24),
        _buildSection('Interests', _profileData?['interest'] ?? []),
        _buildSection('Languages', _profileData?['language'] ?? []),
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _profileData?['about'] ?? 'No description available',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSection(String title, dynamic items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (items is List && items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                items
                    .map(
                      (item) => Chip(
                        label: Text(item.toString()),
                        backgroundColor: Colors.red,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    )
                    .toList(),
          )
        else
          Text(
            'No $title available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text('Say Hi', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _checkMessagingPermission,
          ),
        ),
        // const SizedBox(height: 12),
        // SizedBox(
        //   width: double.infinity,
        //   child: OutlinedButton.icon(
        //     icon: const Icon(Icons.video_call, color: Colors.red),
        //     label: const Text(
        //       'Video Call',
        //       style: TextStyle(color: Colors.red),
        //     ),
        //     style: OutlinedButton.styleFrom(
        //       side: const BorderSide(color: Colors.red),
        //       padding: const EdgeInsets.symmetric(vertical: 12),
        //     ),
        //     onPressed: () {
        //       Get.to(
        //         VideoCallScreen(
        //           userName: _profileData?['name'] ?? 'No Name',
        //           callID: widget.userId,
        //         ),
        //       );
        //     },
        //   ),
        // ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.phone, color: Colors.red),
            label: const Text(
              'Audio Call',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              Get.to(
                AudioCallScreen(
                  userName: _profileData?['name'] ?? 'No Name',
                  profileImageUrl: _profileData?['profile_image'] ?? '',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
