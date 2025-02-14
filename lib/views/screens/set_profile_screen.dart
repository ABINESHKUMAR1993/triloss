import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/constants/main_colors.dart';
import 'package:trilo_app/views/screens/language_screen.dart';
import 'package:trilo_app/views/widgets/button.dart';

class SetProfileScreen extends StatefulWidget {
  const SetProfileScreen({super.key});

  @override
  State<SetProfileScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<SetProfileScreen> {
  String? selectedGender;
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final RxBool _isLoading = false.obs;

  File? _profileImage;

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: cPrimaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = dateFormat.format(picked);
      });
    }
  }

  Future<void> setProfile() async {
    final String name = _nameController.text.trim();
    final String gender = selectedGender ?? '';
    final String dob = _dateController.text;

    if (name.isEmpty || gender.isEmpty || dob.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      debugPrint("Error: All fields are required.");
      return;
    }

    setState(() {
      _isLoading.value = true;
    });

    try {
      final url = Uri.parse('$baseUrl/set_profile');
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';

      final request =
          http.MultipartRequest('POST', url)
            ..headers.addAll({
              "Accept": "application/json",
              "Content-Type": "application/json",
              "x-api-key": apiKey,
              "Authorization": "Bearer $authToken",
            })
            ..fields['name'] = name
            ..fields['gender'] = gender.toLowerCase()
            ..fields['dob'] = dob;

      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            _profileImage!.path,
          ),
        );
      }

      debugPrint("Sending request to $url");

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${responseBody.body}");

      final responseJson = json.decode(responseBody.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        await prefs.setString('user_id', responseJson['data']['user_id']);
        await prefs.setString('name', name);
        await prefs.setString('gender', gender);
        await prefs.setString('dob', dob);
        await prefs.setString(
          'profile_image',
          responseJson['data']['profile_image'],
        );

        Get.snackbar("Success", "Profile updated successfully");
        debugPrint("Profile updated successfully");
        Get.to(() => const LanguageScreen());
      } else {
        Get.snackbar(
          "Error",
          responseJson['message'] ?? "Failed to update profile",
        );
        debugPrint("Error: ${responseJson['message']}");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
      debugPrint("Network error: $e");
    } finally {
      setState(() {
        _isLoading.value = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: const Text(
                  'Set Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Profile Image',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                        child:
                            _profileImage == null
                                ? Icon(Icons.camera_alt, color: Colors.white)
                                : null,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ), // Add space after the profile image
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Nick name',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter first name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: cPrimaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Gender dropdown
              const Text(
                'Who are you',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: selectedGender,
                hint: const Text('Gender'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: cPrimaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items:
                    ['Male', 'Female', 'Other']
                        .map(
                          (String value) => DropdownMenuItem<String?>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'DOB',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: cPrimaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const Spacer(),
              Button(
                onTap: setProfile, // Call the setProfile method
                text: 'Submit',
                isDefault: true,
                isLoading: _isLoading, // Now pass the RxBool
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
