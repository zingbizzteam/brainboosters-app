import 'package:brainboosters_app/screens/authentication/user_setup/widgets/avatar_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/name_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/personal_info_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/academic_step.dart';
import 'package:brainboosters_app/screens/authentication/user_setup/widgets/preferences_step.dart';
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
  bool _isEditing = false;

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
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

  // FIXED: Structured academic data instead of free text
  String? selectedGrade;
  String? selectedBoard;
  String? selectedInterest;
  String? selectedState;
  String? selectedCity;

  // Original data for comparison
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalAvatarUrl;

  // FIXED: Indian education system data
  final List<Map<String, String>> _gradeOptions = [
    {'value': 'class_1', 'display': 'Class 1'},
    {'value': 'class_2', 'display': 'Class 2'},
    {'value': 'class_3', 'display': 'Class 3'},
    {'value': 'class_4', 'display': 'Class 4'},
    {'value': 'class_5', 'display': 'Class 5'},
    {'value': 'class_6', 'display': 'Class 6'},
    {'value': 'class_7', 'display': 'Class 7'},
    {'value': 'class_8', 'display': 'Class 8'},
    {'value': 'class_9', 'display': 'Class 9'},
    {'value': 'class_10', 'display': 'Class 10'},
    {'value': 'class_11', 'display': 'Class 11'},
    {'value': 'class_12', 'display': 'Class 12'},
    {'value': 'ug_1st_year', 'display': 'UG 1st Year (BA/BSc/BCom)'},
    {'value': 'ug_2nd_year', 'display': 'UG 2nd Year (BA/BSc/BCom)'},
    {'value': 'ug_3rd_year', 'display': 'UG 3rd Year (BA/BSc/BCom)'},
    {'value': 'btech_1st_year', 'display': 'B.Tech 1st Year'},
    {'value': 'btech_2nd_year', 'display': 'B.Tech 2nd Year'},
    {'value': 'btech_3rd_year', 'display': 'B.Tech 3rd Year'},
    {'value': 'btech_4th_year', 'display': 'B.Tech 4th Year'},
    {'value': 'mbbs_1st_year', 'display': 'MBBS 1st Year'},
    {'value': 'mbbs_2nd_year', 'display': 'MBBS 2nd Year'},
    {'value': 'mbbs_3rd_year', 'display': 'MBBS 3rd Year'},
    {'value': 'mbbs_4th_year', 'display': 'MBBS 4th Year'},
    {'value': 'mbbs_5th_year', 'display': 'MBBS 5th Year'},
    {'value': 'pg_1st_year', 'display': 'PG 1st Year (MA/MSc/MCom)'},
    {'value': 'pg_2nd_year', 'display': 'PG 2nd Year (MA/MSc/MCom)'},
    {'value': 'mba_1st_year', 'display': 'MBA 1st Year'},
    {'value': 'mba_2nd_year', 'display': 'MBA 2nd Year'},
    {'value': 'mtech_1st_year', 'display': 'M.Tech 1st Year'},
    {'value': 'mtech_2nd_year', 'display': 'M.Tech 2nd Year'},
    {'value': 'phd_1st_year', 'display': 'PhD 1st Year'},
    {'value': 'phd_2nd_year', 'display': 'PhD 2nd Year'},
    {'value': 'phd_3rd_year', 'display': 'PhD 3rd Year'},
    {'value': 'phd_4th_year', 'display': 'PhD 4th Year'},
    {'value': 'working_professional', 'display': 'Working Professional'},
    {'value': 'other', 'display': 'Other'},
  ];

  final List<Map<String, String>> _boardOptions = [
    {'value': 'cbse', 'display': 'CBSE'},
    {'value': 'icse', 'display': 'ICSE'},
    {'value': 'state_board', 'display': 'State Board'},
    {'value': 'igcse', 'display': 'IGCSE'},
    {'value': 'ib', 'display': 'International Baccalaureate (IB)'},
    {'value': 'nios', 'display': 'NIOS'},
    {'value': 'other', 'display': 'Other'},
  ];

  final List<Map<String, String>> _interestOptions = [
    {'value': 'mathematics', 'display': 'Mathematics'},
    {'value': 'physics', 'display': 'Physics'},
    {'value': 'chemistry', 'display': 'Chemistry'},
    {'value': 'biology', 'display': 'Biology'},
    {'value': 'computer_science', 'display': 'Computer Science'},
    {'value': 'engineering', 'display': 'Engineering'},
    {'value': 'medicine', 'display': 'Medicine'},
    {'value': 'commerce', 'display': 'Commerce'},
    {'value': 'economics', 'display': 'Economics'},
    {'value': 'english', 'display': 'English'},
    {'value': 'hindi', 'display': 'Hindi'},
    {'value': 'history', 'display': 'History'},
    {'value': 'geography', 'display': 'Geography'},
    {'value': 'political_science', 'display': 'Political Science'},
    {'value': 'arts', 'display': 'Arts'},
    {'value': 'music', 'display': 'Music'},
    {'value': 'sports', 'display': 'Sports'},
    {'value': 'competitive_exams', 'display': 'Competitive Exams (JEE/NEET/UPSC)'},
    {'value': 'languages', 'display': 'Languages'},
    {'value': 'technology', 'display': 'Technology'},
    {'value': 'other', 'display': 'Other'},
  ];

  final Map<String, List<String>> _indianStatesAndCities = {
    'Andhra Pradesh': ['Hyderabad', 'Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore'],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Pasighat'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Korba', 'Bilaspur', 'Durg'],
    'Delhi': ['New Delhi', 'Central Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi'],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Yamunanagar'],
    'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Solan', 'Mandi'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kollam'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik'],
    'Manipur': ['Imphal', 'Thoubal', 'Bishnupur'],
    'Meghalaya': ['Shillong', 'Tura', 'Jowai'],
    'Mizoram': ['Aizawl', 'Lunglei', 'Saiha'],
    'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner'],
    'Sikkim': ['Gangtok', 'Namchi', 'Gyalshing'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Khammam'],
    'Tripura': ['Agartala', 'Dharmanagar', 'Udaipur'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Ghaziabad', 'Agra', 'Varanasi'],
    'Uttarakhand': ['Dehradun', 'Haridwar', 'Roorkee', 'Haldwani'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
  };

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
        _isEditing = userProfile != null &&
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
          // FIXED: Use structured data instead of free text
          selectedGrade = _validateDropdownValue(
              studentProfile['grade_level'], _gradeOptions);
          selectedBoard = _validateDropdownValue(
              studentProfile['education_board'], _boardOptions);
          selectedInterest = _validateDropdownValue(
              studentProfile['primary_interest'], _interestOptions);
          selectedState = studentProfile['state'];
          selectedCity = studentProfile['city'];
          
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

      // Fallback to auth.users metadata
      final meta = user.userMetadata;
      if (meta != null) {
        if (firstNameController.text.isEmpty && lastNameController.text.isEmpty) {
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

  // FIXED: Helper method to validate dropdown values
  String? _validateDropdownValue(String? value, List<Map<String, String>> options) {
    if (value == null) return null;
    
    // Check if value exists in options
    final exists = options.any((option) => option['value'] == value);
    if (exists) return value;
    
    // Try to migrate old values to new format
    final migratedValue = _migrateOldValue(value);
    final migratedExists = options.any((option) => option['value'] == migratedValue);
    
    return migratedExists ? migratedValue : null;
  }

  // FIXED: Migration logic for old grade values
  String _migrateOldValue(String oldValue) {
    switch (oldValue) {
      case 'Grade 1': return 'class_1';
      case 'Grade 2': return 'class_2';
      case 'Grade 3': return 'class_3';
      case 'Grade 4': return 'class_4';
      case 'Grade 5': return 'class_5';
      case 'Grade 6': return 'class_6';
      case 'Grade 7': return 'class_7';
      case 'Grade 8': return 'class_8';
      case 'Grade 9': return 'class_9';
      case 'Grade 10': return 'class_10';
      case 'Grade 11': return 'class_11';
      case 'Grade 12': return 'class_12';
      case 'College': return 'ug_1st_year';
      case 'College Sophomore': return 'ug_2nd_year';
      case 'University': return 'ug_1st_year';
      case '12th Grade': return 'class_12';
      default: return 'other';
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
        await _deleteAllUserAvatars(user.id);
        
        final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(fileName, avatarFile!);

        finalAvatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // Check if name or avatar changed
      final nameChanged = _originalFirstName != firstNameController.text.trim() ||
          _originalLastName != lastNameController.text.trim();
      final avatarChanged = _originalAvatarUrl != finalAvatarUrl;

      // Update auth.users metadata if needed
      if (nameChanged || avatarChanged) {
        final currentMeta = user.userMetadata ?? {};
        final updatedMeta = Map<String, dynamic>.from(currentMeta);
        
        if (nameChanged) {
          updatedMeta['full_name'] = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
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

      // Get or set user_type
      String userType = 'student';
      final currentProfile = await Supabase.instance.client
          .from('user_profiles')
          .select('user_type')
          .eq('id', user.id)
          .maybeSingle();

      if (currentProfile != null && currentProfile['user_type'] != null) {
        userType = currentProfile['user_type'];
      }

      // Upsert user_profiles
      await Supabase.instance.client.from('user_profiles').upsert({
        'id': user.id,
        'user_type': userType,
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'phone': fullPhoneNumber ?? phoneController.text.trim(),
        'date_of_birth': selectedDate?.toIso8601String().split('T')[0],
        'gender': selectedGender,
        'avatar_url': finalAvatarUrl,
        'email_verified': true,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Check if student exists
      final studentRecord = await Supabase.instance.client
          .from('students')
          .select('id,student_id')
          .eq('user_id', user.id)
          .maybeSingle();

      // FIXED: Prepare structured student data
      final studentData = {
        'user_id': user.id,
        'grade_level': selectedGrade,
        'education_board': selectedBoard,
        'primary_interest': selectedInterest,
        'state': selectedState,
        'city': selectedCity,
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

  Future<void> _deleteAllUserAvatars(String userId) async {
    try {
      final files = await Supabase.instance.client.storage
          .from('avatars')
          .list(path: userId);

      if (files.isNotEmpty) {
        final filePaths = files.map((file) => '$userId/${file.name}').toList();
        await Supabase.instance.client.storage
            .from('avatars')
            .remove(filePaths);
        debugPrint('Deleted ${filePaths.length} old avatar(s) for user $userId');
      }
    } catch (e) {
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
        if (fullPhoneNumber == null || selectedDate == null || selectedGender == null) {
          _showError('Please complete all personal information');
          return false;
        }
        break;
      case 3:
        if (selectedGrade == null) {
          _showError('Please select your education level');
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
                          _isEditing ? 'Editing profile for:' : 'Setting up profile for:',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                        _isEditing ? 'Update Your Profile' : 'Complete Your Profile',
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
                      onPressed: _isLoading ? null : () => setState(() => _currentStep--),
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
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4845C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                              : Text(_isEditing ? 'Update Profile' : 'Complete Setup'),
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
        return AcademicStep(
          selectedGrade: selectedGrade,
          selectedBoard: selectedBoard,
          selectedInterest: selectedInterest,
          selectedState: selectedState,
          selectedCity: selectedCity,
          schoolController: schoolController,
          parentNameController: parentNameController,
          parentPhoneController: parentPhoneController,
          parentEmailController: parentEmailController,
          gradeOptions: _gradeOptions,
          boardOptions: _boardOptions,
          interestOptions: _interestOptions,
          statesAndCities: _indianStatesAndCities,
          onGradeChanged: (value) => setState(() => selectedGrade = value),
          onBoardChanged: (value) => setState(() => selectedBoard = value),
          onInterestChanged: (value) => setState(() => selectedInterest = value),
          onStateChanged: (value) => setState(() {
            selectedState = value;
            selectedCity = null;
          }),
          onCityChanged: (value) => setState(() => selectedCity = value),
        );
      case 4:
        return PreferencesStep(
          selectedLanguage: selectedLanguage,
          selectedGoals: selectedGoals,
          onLanguageChanged: (val) => setState(() => selectedLanguage = val),
          onGoalToggle: (courseName) => setState(() {
            selectedGoals.contains(courseName)
                ? selectedGoals.remove(courseName)
                : selectedGoals.add(courseName);
          }),
        );
      default:
        return const SizedBox();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    schoolController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    parentEmailController.dispose();
    super.dispose();
  }
}
