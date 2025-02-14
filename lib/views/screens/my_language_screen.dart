import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo_app/constants/constants.dart';

class MyLanguageScreen extends StatefulWidget {
  const MyLanguageScreen({super.key});

  @override
  State<MyLanguageScreen> createState() => _MyLanguageScreenState();
}

class _MyLanguageScreenState extends State<MyLanguageScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _languages = []; // Change type to dynamic
  String _selectedLanguageId = '';

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    final url = Uri.parse('$baseUrl/my_languages');
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
          final List<dynamic> languagesData = data['data']['languages'];
          setState(() {
            _languages =
                languagesData
                    .map(
                      (lang) => {
                        'id': lang['language_id'],
                        'name': lang['language_name'],
                      },
                    )
                    .toList();
          });
        } else {
          _showError('Failed to fetch languages: ${data['message']}');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (error) {
      _showError('An error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveLanguageSelection() {
    if (_selectedLanguageId.isEmpty) {
      _showError('Please select a language.');
      return;
    }
    // Perform save operation here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Language selection saved!')));
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
          'My Language',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child:
                          _languages.isEmpty
                              ? const Center(
                                child: Text('No languages available.'),
                              )
                              : ListView.builder(
                                itemCount: _languages.length,
                                itemBuilder: (context, index) {
                                  final language = _languages[index];
                                  return _LanguageOption(
                                    label: language['name']!,
                                    isSelected:
                                        _selectedLanguageId == language['id'],
                                    onTap: () {
                                      setState(() {
                                        _selectedLanguageId = language['id']!;
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                    // Save Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveLanguageSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.amber : Colors.black,
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
