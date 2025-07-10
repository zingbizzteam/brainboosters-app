import 'package:brainboosters_app/screens/authentication/user_setup/widgets/avatar_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/goal_selection_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/language_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/name_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/personal_info_step.dart';
import 'package:brainboosters_app/ui/navigation/student_routes/student_routes.dart';
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
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
  bool _isEditing = false; // Track if editing existing data

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final gradeController = TextEditingController();
  final schoolController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final parentEmailController = TextEditingController();

  // Data
  String? fullPhoneNumber;
  String? parentFullPhoneNumber;
  DateTime? selectedDate;
  String? selectedGender;
  String? selectedLanguage;
  String? avatarUrl;
  File? avatarFile;
  final List<String> selectedGoals = [];
  String phoneIsoCode = 'IN';
  String parentPhoneIsoCode = 'IN';

  // Original data for comparison
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalAvatarUrl;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  Future<void> _prefillData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Check if user profile exists
      final userProfile = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // Check if student record exists
      final studentProfile = await Supabase.instance.client
          .from('students')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      setState(() {
        _isEditing =
            userProfile != null &&
            userProfile['onboarding_completed'] == true &&
            studentProfile != null;
      });

      // Prefill from user_profiles table
      if (userProfile != null) {
        setState(() {
          firstNameController.text = userProfile['first_name'] ?? '';
          lastNameController.text = userProfile['last_name'] ?? '';
          phoneController.text = userProfile['phone'] ?? '';
          fullPhoneNumber = userProfile['phone'];
          selectedDate = userProfile['date_of_birth'] != null
              ? DateTime.parse(userProfile['date_of_birth'])
              : null;
          selectedGender = userProfile['gender'];
          avatarUrl = userProfile['avatar_url'];

          // Store original values for comparison
          _originalFirstName = userProfile['first_name'];
          _originalLastName = userProfile['last_name'];
          _originalAvatarUrl = userProfile['avatar_url'];
        });
      }

      // Prefill from student table if exists
      if (studentProfile != null) {
        setState(() {
          gradeController.text = studentProfile['grade_level'] ?? '';
          schoolController.text = studentProfile['school_name'] ?? '';
          parentNameController.text = studentProfile['parent_name'] ?? '';
          parentPhoneController.text = studentProfile['parent_phone'] ?? '';
          parentFullPhoneNumber = studentProfile['parent_phone'];
          parentEmailController.text = studentProfile['parent_email'] ?? '';
          selectedLanguage = studentProfile['preferred_learning_style'];

          // Handle learning goals array
          final goals = studentProfile['learning_goals'];
          if (goals is List) {
            selectedGoals.clear();
            selectedGoals.addAll(goals.cast<String>());
          }
        });
      }

      // Fallback to auth.users metadata (for Google login or missing data)
      final meta = user.userMetadata;
      if (meta != null) {
        // Only use metadata if profile data is empty
        if (firstNameController.text.isEmpty &&
            lastNameController.text.isEmpty) {
          final fullName = meta['full_name'] ?? '';
          final firstName = meta['first_name'] ?? '';
          final lastName = meta['last_name'] ?? '';

          setState(() {
            if (firstName.isNotEmpty) {
              firstNameController.text = firstName;
            } else if (fullName.isNotEmpty) {
              final nameParts = fullName.split(' ');
              firstNameController.text = nameParts.first;
              if (nameParts.length > 1) {
                lastNameController.text = nameParts.skip(1).join(' ');
              }
            }

            if (lastName.isNotEmpty) {
              lastNameController.text = lastName;
            }

            _originalFirstName = firstNameController.text;
            _originalLastName = lastNameController.text;
          });
        }

        // Use metadata avatar if no profile avatar
        if (avatarUrl == null && meta['avatar_url'] != null) {
          setState(() {
            avatarUrl = meta['avatar_url'];
            _originalAvatarUrl = avatarUrl;
          });
        }
      }
    } catch (e) {
      debugPrint('Error prefilling: $e');
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go(AuthRoutes.authSelection);
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser!;

      // Upload new avatar if selected
      String? finalAvatarUrl = avatarUrl;
      if (avatarFile != null) {
        // Delete all existing avatars for this user first
        await _deleteAllUserAvatars(user.id);

        // Upload new avatar
        final fileName =
            '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(fileName, avatarFile!);
        finalAvatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // Check if name or avatar changed to update auth.users
      final nameChanged =
          _originalFirstName != firstNameController.text.trim() ||
          _originalLastName != lastNameController.text.trim();
      final avatarChanged = _originalAvatarUrl != finalAvatarUrl;

      // Update auth.users metadata if name or avatar changed
      if (nameChanged || avatarChanged) {
        final currentMeta = user.userMetadata ?? {};
        final updatedMeta = Map<String, dynamic>.from(currentMeta);

        if (nameChanged) {
          updatedMeta['full_name'] =
              '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
          updatedMeta['first_name'] = firstNameController.text.trim();
          updatedMeta['last_name'] = lastNameController.text.trim();
        }

        if (avatarChanged && finalAvatarUrl != null) {
          updatedMeta['avatar_url'] = finalAvatarUrl;
        }

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: updatedMeta),
        );
      }

      // Get or set user_type (default to student if not exists)
    String userType = 'student';
    final currentProfile = await Supabase.instance.client
        .from('user_profiles')
        .select('user_type')
        .eq('id', user.id)
        .maybeSingle();
    if (currentProfile != null && currentProfile['user_type'] != null) {
      userType = currentProfile['user_type'];
    }

    // Upsert user_profiles (safe)
    await Supabase.instance.client.from('user_profiles').upsert({
      'id': user.id,
      'user_type': userType,
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'phone': fullPhoneNumber ?? phoneController.text.trim(),
      'date_of_birth': selectedDate?.toIso8601String().split('T')[0],
      'gender': selectedGender,
      'avatar_url': avatarUrl,
      'email_verified': true,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // --- STUDENT LOGIC ---
    // Check if student exists
    final studentRecord = await Supabase.instance.client
        .from('students')
        .select('id,student_id')
        .eq('user_id', user.id)
        .maybeSingle();

    // Prepare student data
    final studentData = {
      'user_id': user.id,
      'grade_level': gradeController.text.trim().isNotEmpty ? gradeController.text.trim() : null,
      'school_name': schoolController.text.trim().isNotEmpty ? schoolController.text.trim() : null,
      'parent_name': parentNameController.text.trim().isNotEmpty ? parentNameController.text.trim() : null,
      'parent_phone': parentFullPhoneNumber ?? (parentPhoneController.text.trim().isNotEmpty ? parentPhoneController.text.trim() : null),
      'parent_email': parentEmailController.text.trim().isNotEmpty ? parentEmailController.text.trim() : null,
      'learning_goals': selectedGoals,
      'preferred_learning_style': selectedLanguage,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (studentRecord != null) {
      // Update existing student
      await Supabase.instance.client
          .from('students')
          .update(studentData)
          .eq('user_id', user.id);
    } else {
      // Insert new student
      studentData['created_at'] = DateTime.now().toIso8601String();
      studentData['student_id'] = await _generateStudentId();
      await Supabase.instance.client.from('students').insert(studentData);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Profile updated successfully!' : 'Profile setup completed!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(StudentRoutes.home);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
    debugPrint('Save error: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
  }
  
  // Simplified delete method - delete all files in user folder
  Future<void> _deleteAllUserAvatars(String userId) async {
    try {
      // List all files in the user's folder
      final files = await Supabase.instance.client.storage
          .from('avatars')
          .list(path: userId);

      if (files.isNotEmpty) {
        // Get all file paths
        final filePaths = files.map((file) => '$userId/${file.name}').toList();

        // Delete all files at once
        await Supabase.instance.client.storage
            .from('avatars')
            .remove(filePaths);

        debugPrint(
          'Deleted ${filePaths.length} old avatar(s) for user $userId',
        );
      }
    } catch (e) {
      // Don't throw error if deletion fails, just log it
      debugPrint('Failed to delete old avatars: $e');
    }
  }

  Future<String> _generateStudentId() async {
    try {
      final response = await Supabase.instance.client
          .from('students')
          .select('student_id')
          .order('created_at', ascending: false)
          .limit(1);

      int nextNumber = 1;
      if (response.isNotEmpty) {
        final lastId = response.first['student_id'] as String;
        final numberPart = lastId.replaceAll('STU', '');
        nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
      }
      return 'STU${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback to timestamp-based ID
      return 'STU${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (firstNameController.text.trim().isEmpty ||
            lastNameController.text.trim().isEmpty) {
          _showError('Please enter your full name');
          return false;
        }
        break;
      case 1:
        if (fullPhoneNumber == null ||
            selectedDate == null ||
            selectedGender == null) {
          _showError('Please complete all personal information');
          return false;
        }
        break;
      case 3:
        if (gradeController.text.trim().isEmpty) {
          _showError('Please enter your grade level');
          return false;
        }
        break;
      case 4:
        if (selectedLanguage == null || selectedGoals.isEmpty) {
          _showError('Please complete learning preferences');
          return false;
        }
        break;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with email and logout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing
                              ? 'Editing profile for:'
                              : 'Setting up profile for:',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Logout'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing
                            ? 'Update Your Profile'
                            : 'Complete Your Profile',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5DADE2),
                        ),
                      ),
                      Text(
                        '${_currentStep + 1}/5',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? const Color(0xFF5DADE2)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStep(),
              ),
            ),

            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _currentStep--),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Color(0xFF5DADE2)),
                      ),
                    )
                  else
                    const SizedBox(),

                  _currentStep < 4
                      ? FloatingActionButton(
                          backgroundColor: const Color(0xFFD4845C),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_validateStep()) {
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
                            backgroundColor: const Color(0xFFD4845C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          onPressed: _isLoading ? null : _saveData,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Update Profile'
                                      : 'Complete Setup',
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

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return NameStep(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        );
      case 1:
        return PersonalInfoStep(
          fullPhoneNumber: fullPhoneNumber,
          phoneIsoCode: phoneIsoCode,
          selectedDate: selectedDate,
          selectedGender: selectedGender,
          onPhoneChanged: (val) => setState(() => fullPhoneNumber = val),
          onIsoCodeChanged: (val) => setState(() => phoneIsoCode = val),
          onDateChanged: (date) => setState(() => selectedDate = date),
          onGenderChanged: (gender) => setState(() => selectedGender = gender),
        );
      case 2:
        return AvatarStep(
          avatarFile: avatarFile,
          avatarUrl: avatarUrl,
          onImagePicked: (file) => setState(() {
            avatarFile = file;
            avatarUrl = null;
          }),
        );
      case 3:
        return _buildAcademicStep();
      case 4:
        return _buildPreferencesStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAcademicStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Academic Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: gradeController,
            decoration: InputDecoration(
              labelText: 'Grade Level (e.g., 12th Grade, College)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.school),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: schoolController,
            decoration: InputDecoration(
              labelText: 'School/College Name (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.location_city),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Parent/Guardian Information (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: parentNameController,
            decoration: InputDecoration(
              labelText: 'Parent/Guardian Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: parentPhoneController,
            decoration: InputDecoration(
              labelText: 'Parent/Guardian Phone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: parentEmailController,
            decoration: InputDecoration(
              labelText: 'Parent/Guardian Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          const Text(
            'Learning Preferences',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Language selection
          LanguageStep(
            selectedLanguage: selectedLanguage,
            onChanged: (val) => setState(() => selectedLanguage = val),
          ),

          const SizedBox(height: 24),

          // Course selection - Fixed height container
          SizedBox(
            height: 500, // Fixed height to prevent overflow
            child: GoalSelectionStep(
              selectedGoals: selectedGoals,
              onCourseToggle: (courseName) => setState(() {
                selectedGoals.contains(courseName)
                    ? selectedGoals.remove(courseName)
                    : selectedGoals.add(courseName);
              }),
            ),
          ),

          // Bottom padding to account for navigation buttons
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    gradeController.dispose();
    schoolController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    parentEmailController.dispose();
    super.dispose();
  }
}
