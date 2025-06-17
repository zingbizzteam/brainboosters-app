import 'package:brainboosters_app/screens/authentication/user_setup/widgets/avatar_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/course_selection_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/language_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/name_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/personal_info_step.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class UserSetupPage extends StatefulWidget {
  const UserSetupPage({super.key});

  @override
  State<UserSetupPage> createState() => _UserSetupPageState();
}

class _UserSetupPageState extends State<UserSetupPage> {
  int _currentStep = 0;
  bool _isLoading = false;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String? fullPhoneNumber;
  DateTime? selectedDate;
  String? selectedLanguage;
  String? avatarUrl;
  File? avatarFile;
  final List<String> selectedCourses = [];
  String phoneIsoCode = 'IN';

  @override
  void initState() {
    super.initState();
    _prefillFromGoogleIfAvailable();
  }

  void _prefillFromGoogleIfAvailable() {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata;
    // For Google login, userMetadata may contain full_name and avatar_url
    if (meta != null) {
      if (nameController.text.isEmpty && meta['full_name'] != null) {
        nameController.text = meta['full_name'];
      }
      if (avatarUrl == null && meta['avatar_url'] != null) {
        avatarUrl = meta['avatar_url'];
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<String?> _uploadAvatar() async {
    if (avatarFile == null) return avatarUrl; // Use Google avatar if present
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final fileName =
          'avatar_${user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, avatarFile!);
      return Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      return null;
    }
  }

  Future<void> _saveUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      if (avatarFile != null) {
        avatarUrl = await _uploadAvatar();
      }
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'name': nameController.text.trim(),
        'phone': fullPhoneNumber ?? phoneController.text.trim(),
        'date_of_birth': selectedDate?.toIso8601String(),
        'language': selectedLanguage,
        'avatar_url': avatarUrl,
        'selected_courses': selectedCourses,
        'onboarding_completed': true,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setup completed successfully!')),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your name')),
          );
          return false;
        }
        break;
      case 1:
        if (fullPhoneNumber == null || fullPhoneNumber!.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid phone number')),
          );
          return false;
        }
        if (selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your date of birth')),
          );
          return false;
        }
        break;
      case 3:
        if (selectedLanguage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a language')),
          );
          return false;
        }
        break;
      case 4:
        if (selectedCourses.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one course')),
          );
          return false;
        }
        break;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildStepContent(_currentStep),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _currentStep--),
                      child: const Text('Back', style: TextStyle(fontSize: 16)),
                    )
                  else
                    const SizedBox(width: 72),
                  _currentStep < 4
                      ? FloatingActionButton(
                          backgroundColor: Colors.black87,
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_validateCurrentStep()) {
                                    setState(() => _currentStep++);
                                  }
                                },
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _saveUserData,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Finish',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return buildNameStep(nameController);
      case 1:
        return PersonalInfoStep(
          fullPhoneNumber: fullPhoneNumber,
          phoneIsoCode: phoneIsoCode,
          selectedDate: selectedDate,
          onPhoneChanged: (val) => setState(() => fullPhoneNumber = val),
          onIsoCodeChanged: (val) => setState(() => phoneIsoCode = val),
          onDateChanged: (date) => setState(() => selectedDate = date),
        );
      case 2:
        return AvatarStep(
          avatarFile: avatarFile,
          avatarUrl: avatarUrl,
          onImagePicked: (file) {
            setState(() {
              avatarFile = file;
              avatarUrl = null;
            });
          },
        );
      case 3:
        return LanguageStep(
          selectedLanguage: selectedLanguage,
          onChanged: (val) => setState(() => selectedLanguage = val),
        );
      case 4:
        return CourseSelectionStep(
          selectedCourses: selectedCourses,
          onCourseToggle: (courseName) {
            setState(() {
              if (selectedCourses.contains(courseName)) {
                selectedCourses.remove(courseName);
              } else {
                selectedCourses.add(courseName);
              }
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
