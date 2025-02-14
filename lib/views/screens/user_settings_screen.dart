import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trilo_app/views/screens/my_language_screen.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

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
          'User Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingItem(
            icon: Icons.headset_mic,
            title: 'Support',
            onTap: () {
              // Handle support tap
            },
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.block,
            title: 'Block List',
            onTap: () {
              // Handle block list tap
            },
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.language,
            title: 'My Language',
            onTap: () {
              Get.to(() => MyLanguageScreen());
            },
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            isDestructive: true,
            onTap: () {
              // Handle delete account tap
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? Colors.red : Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
