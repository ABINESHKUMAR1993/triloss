import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // To make HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilo_app/constants/constants.dart';
import 'package:trilo_app/views/screens/home_screen.dart';
import 'package:trilo_app/views/widgets/button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageScreen> {
  List<LanguageOption> languages = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    getLanguages();
  }

  // Fetch languages from the API
  Future<void> getLanguages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Reset error message
    });

    final url = Uri.parse('$baseUrl/get_language');
    final prefs = await SharedPreferences.getInstance();
    final authToken =
        prefs.getString('auth_token') ??
        ''; // Fix here: added empty string fallback for null

    try {
      debugPrint('Fetching languages from: $url'); // Debug log for the URL
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization":
              "Bearer $authToken", // Ensure that the token is not null
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final languageData = data['data'] as List;

        // Debug log for fetched data
        debugPrint('Languages fetched successfully: $languageData');

        // Map the response data to a list of LanguageOption objects
        setState(() {
          languages =
              languageData.map((item) {
                return LanguageOption(
                  name: item['name'],
                  imagePath: item['image_url'],
                  isSelected: false,
                );
              }).toList();
        });
      } else {
        // Handle failure based on status code
        debugPrint(
          'Failed to load languages. Status Code: ${response.statusCode}',
        );
        setState(() {
          _errorMessage = 'Failed to load languages. Please try again later.';
        });
      }
    } catch (e) {
      debugPrint(
        'Error while fetching languages: $e',
      ); // Debug log for the error
      setState(() {
        _errorMessage =
            'An error occurred. Please check your internet connection or try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save selected languages
  Future<void> saveSelectedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> selectedLanguageNames =
        languages
            .where((language) => language.isSelected)
            .map((language) => language.name)
            .toList();

    // Debug log for selected languages
    debugPrint('Saving selected languages: $selectedLanguageNames');

    // Save the selected languages in SharedPreferences
    await prefs.setStringList('selected_languages', selectedLanguageNames);
  }

  // Select language and make an API call to save the selection
  Future<void> _selectLanguage() async {
    final url = Uri.parse('$baseUrl/select_language');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the list of selected language names
      List<String> selectedLanguages =
          languages
              .where((language) => language.isSelected)
              .map((language) => language.name)
              .toList();

      // Debug log for selected languages
      debugPrint('Selected languages: $selectedLanguages');

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({'languages': selectedLanguages}),
      );

      if (response.statusCode == 200) {
        // Handle success
        setState(() {
          _successMessage = 'Languages saved successfully!';
        });
        debugPrint('Languages saved successfully');
      } else {
        // Handle failure
        debugPrint(
          'Failed to select languages. Status Code: ${response.statusCode}',
        );
        setState(() {
          _errorMessage = 'Failed to select languages. Please try again later.';
        });
      }
    } catch (e) {
      debugPrint('Error while selecting languages: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.pink,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select languages',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Show all your languages proudly to get better matches',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // Show a loading indicator while the languages are being fetched
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                  : _successMessage.isNotEmpty
                  ? Center(
                    child: Text(
                      _successMessage,
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                  : Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        return LanguageCard(
                          language: languages[index],
                          onTap: () {
                            setState(() {
                              languages[index].isSelected =
                                  !languages[index].isSelected;
                            });
                            debugPrint(
                              'Language ${languages[index].name} selected: ${languages[index].isSelected}',
                            );
                          },
                        );
                      },
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Button(
                  onTap: () {
                    saveSelectedLanguages(); // Save selected languages
                    _selectLanguage();

                    Get.snackbar(
                      "Success",
                      "Languages updated successfully",
                    ); // Select language and send it to the backend
                    Get.to(() => HomeScreen());
                  },
                  text: 'Save',
                  isDefault: true,
                  isLoading: RxBool(false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String name;
  final String imagePath;
  bool isSelected;

  LanguageOption({
    required this.name,
    required this.isSelected,
    required this.imagePath,
  });
}

class LanguageCard extends StatelessWidget {
  final LanguageOption language;
  final VoidCallback onTap;

  const LanguageCard({super.key, required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                language.isSelected
                    ? const Color(0xFFE91E63)
                    : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a loading indicator and error handling for the image
            Image.network(
              language.imagePath,
              width: 40,
              height: 40,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // If the image is loaded, display it
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              language.name,
              style: TextStyle(
                fontSize: 14,
                color:
                    language.isSelected
                        ? const Color(0xFFE91E63)
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
