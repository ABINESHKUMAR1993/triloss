import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo_app/constants/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  String _dateOfBirth = '24/05/1995';
  String _selectedGender = 'Female';
  String _selectedLanguage = 'English';
  String _selectedCountry = 'Nigeria';
  String _userName = 'Melissa Peters';
  String _profileImage = 'assets/images/png/user.png';
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final List<String> _genders = ['Female', 'Male', 'Other'];
  final List<String> _languages = ['English', 'Tamil', 'French', 'Spanish'];
  final List<String> _countries = ['Nigeria', 'USA', 'Canada', 'India', 'UK'];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = _userName;
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _interestsController.dispose();
    _aboutController.dispose();
    super.dispose();
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
        if (data['status'] == 'success') {
          setState(() {
            _userName = data['data']['name'];
            _dateOfBirth = data['data']['dob'];
            _selectedGender = data['data']['gender'];
            _profileImage = data['data']['profile_image'];
            _nameController.text = _userName;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile retrieval failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error fetching profile')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _profileUpdate() async {
    final url = Uri.parse('$baseUrl/profile_update');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      String profileImageUrl = _profileImage;
      if (_imageFile != null) {
        profileImageUrl = await _uploadImage(_imageFile!);
      }

      final Map<String, dynamic> requestBody = {
        "name": _nameController.text,
        "dob": _dateOfBirth,
        "gender": _selectedGender,
        "interest": [_interestsController.text],
        "country": _selectedCountry,
        "about": _aboutController.text,
        "language": [_selectedLanguage],
        "profile_image": profileImageUrl,
      };

      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _userName = data['data']['name'];
            _dateOfBirth = data['data']['dob'];
            _selectedGender = data['data']['gender'];
            _selectedCountry = data['data']['country'];
            _selectedLanguage = data['data']['language'][0];
            _profileImage = data['data']['profile_image'];
            _nameController.text = _userName;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          print('Profile update failed: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile update failed')),
          );
        }
      } else {
        print('Failed to update profile. Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating profile')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final url = Uri.parse('$baseUrl/upload_image');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['image_url'];
      } else {
        print('Failed to upload image. Status Code: ${response.statusCode}');
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return '';
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.pink,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      _imageFile != null
                                          ? Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          )
                                          : _profileImage.startsWith('http')
                                          ? Image.network(
                                            _profileImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                    ),
                                          )
                                          : Image.asset(
                                            _profileImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                    ),
                                          ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('Name', _nameController),
                      _buildDropdownField('Gender', _selectedGender, _genders, (
                        String? newValue,
                      ) {
                        if (newValue != null) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        }
                      }),
                      GestureDetector(
                        onTap: _selectDate,
                        child: _buildProfileField(
                          'Date of Birth',
                          _dateOfBirth,
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      _buildTextField(
                        'Interests',
                        _interestsController,
                        hint: true,
                      ),
                      _buildDropdownField(
                        'Languages',
                        _selectedLanguage,
                        _languages,
                        (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          }
                        },
                      ),
                      _buildDropdownField(
                        'Country/Region',
                        _selectedCountry,
                        _countries,
                        (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCountry = newValue;
                            });
                          }
                        },
                      ),
                      _buildTextField('About', _aboutController, hint: true),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _profileUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
}

Widget _buildProfileField(String label, String value, IconData? trailingIcon) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: Colors.black54),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdownField(
  String label,
  String selectedValue,
  List<String> options,
  ValueChanged<String?> onChanged,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  options.contains(selectedValue) ? selectedValue : options[0],
              onChanged: onChanged,
              isExpanded: true,
              items:
                  options.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField(
  String label,
  TextEditingController controller, {
  bool hint = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration.collapsed(
              hintText: hint ? 'Write here' : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: hint ? Colors.black38 : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
