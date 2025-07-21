import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedGrade;
  String? _selectedInterest;
  String? _selectedBoard;
  String? _selectedState;
  String? _selectedCity;
  String? _avatarUrl;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSaving = false;

  // FIXED: Proper Indian education system with value-display mapping
  final List<Map<String, String>> _gradeOptions = [
    // School Education (CBSE/ICSE/State Board)
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

    // Undergraduate
    {'value': 'ug_1st_year', 'display': 'UG 1st Year (BA/BSc/BCom)'},
    {'value': 'ug_2nd_year', 'display': 'UG 2nd Year (BA/BSc/BCom)'},
    {'value': 'ug_3rd_year', 'display': 'UG 3rd Year (BA/BSc/BCom)'},

    // Engineering
    {'value': 'btech_1st_year', 'display': 'B.Tech 1st Year'},
    {'value': 'btech_2nd_year', 'display': 'B.Tech 2nd Year'},
    {'value': 'btech_3rd_year', 'display': 'B.Tech 3rd Year'},
    {'value': 'btech_4th_year', 'display': 'B.Tech 4th Year'},

    // Medical
    {'value': 'mbbs_1st_year', 'display': 'MBBS 1st Year'},
    {'value': 'mbbs_2nd_year', 'display': 'MBBS 2nd Year'},
    {'value': 'mbbs_3rd_year', 'display': 'MBBS 3rd Year'},
    {'value': 'mbbs_4th_year', 'display': 'MBBS 4th Year'},
    {'value': 'mbbs_5th_year', 'display': 'MBBS 5th Year'},

    // Postgraduate
    {'value': 'pg_1st_year', 'display': 'PG 1st Year (MA/MSc/MCom)'},
    {'value': 'pg_2nd_year', 'display': 'PG 2nd Year (MA/MSc/MCom)'},
    {'value': 'mba_1st_year', 'display': 'MBA 1st Year'},
    {'value': 'mba_2nd_year', 'display': 'MBA 2nd Year'},
    {'value': 'mtech_1st_year', 'display': 'M.Tech 1st Year'},
    {'value': 'mtech_2nd_year', 'display': 'M.Tech 2nd Year'},

    // PhD and Research
    {'value': 'phd_1st_year', 'display': 'PhD 1st Year'},
    {'value': 'phd_2nd_year', 'display': 'PhD 2nd Year'},
    {'value': 'phd_3rd_year', 'display': 'PhD 3rd Year'},
    {'value': 'phd_4th_year', 'display': 'PhD 4th Year'},

    // Professional
    {'value': 'working_professional', 'display': 'Working Professional'},
    {'value': 'other', 'display': 'Other'},
  ];

  // FIXED: Indian-specific interests
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
    {
      'value': 'competitive_exams',
      'display': 'Competitive Exams (JEE/NEET/UPSC)',
    },
    {'value': 'languages', 'display': 'Languages'},
    {'value': 'technology', 'display': 'Technology'},
    {'value': 'other', 'display': 'Other'},
  ];

  // Education boards in India
  final List<Map<String, String>> _educationBoards = [
    {'value': 'cbse', 'display': 'CBSE'},
    {'value': 'icse', 'display': 'ICSE'},
    {'value': 'state_board', 'display': 'State Board'},
    {'value': 'igcse', 'display': 'IGCSE'},
    {'value': 'ib', 'display': 'International Baccalaureate (IB)'},
    {'value': 'nios', 'display': 'NIOS'},
    {'value': 'other', 'display': 'Other'},
  ];

  // Indian states and major cities
  final Map<String, List<String>> _indianStatesAndCities = {
    'Andhra Pradesh': [
      'Hyderabad',
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Nellore',
    ],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Pasighat'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Korba', 'Bilaspur', 'Durg'],
    'Delhi': [
      'New Delhi',
      'Central Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
      'West Delhi',
    ],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Yamunanagar'],
    'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Solan', 'Mandi'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
    'Kerala': [
      'Thiruvananthapuram',
      'Kochi',
      'Kozhikode',
      'Thrissur',
      'Kollam',
    ],
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
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
    ],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Khammam'],
    'Tripura': ['Agartala', 'Dharmanagar', 'Udaipur'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Ghaziabad', 'Agra', 'Varanasi'],
    'Uttarakhand': ['Dehradun', 'Haridwar', 'Roorkee', 'Haldwani'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  // FIXED: Proper data loading with validation
  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Load profile data
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Load student data
      final studentResponse = await Supabase.instance.client
          .from('students')
          .select()
          .eq('user_id', user.id)
          .single();

      setState(() {
        _firstNameController.text = profileResponse['first_name'] ?? '';
        _lastNameController.text = profileResponse['last_name'] ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = profileResponse['phone'] ?? '';
        _bioController.text = profileResponse['bio'] ?? '';

        // FIXED: Validate grade level exists in options
        final gradeFromDb = studentResponse['grade_level'];
        _selectedGrade = _validateDropdownValue(gradeFromDb, _gradeOptions);

        // FIXED: Validate interest exists in options
        final interestFromDb = studentResponse['primary_interest'];
        _selectedInterest = _validateDropdownValue(
          interestFromDb,
          _interestOptions,
        );

        // Load other fields
        final boardFromDb = studentResponse['education_board'];
        _selectedBoard = _validateDropdownValue(boardFromDb, _educationBoards);

        _selectedState = studentResponse['state'];
        _selectedCity = studentResponse['city'];
        _avatarUrl = profileResponse['avatar_url'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // FIXED: Helper method to validate dropdown values
  String? _validateDropdownValue(
    String? value,
    List<Map<String, String>> options,
  ) {
    if (value == null) return null;

    // Check if value exists in options
    final exists = options.any((option) => option['value'] == value);
    if (exists) return value;

    // Try to migrate old values to new format
    final migratedValue = _migrateOldValue(value);
    final migratedExists = options.any(
      (option) => option['value'] == migratedValue,
    );

    return migratedExists ? migratedValue : null;
  }

  // FIXED: Migration logic for old grade values
  String _migrateOldValue(String oldValue) {
    switch (oldValue) {
      case 'Grade 1':
        return 'class_1';
      case 'Grade 2':
        return 'class_2';
      case 'Grade 3':
        return 'class_3';
      case 'Grade 4':
        return 'class_4';
      case 'Grade 5':
        return 'class_5';
      case 'Grade 6':
        return 'class_6';
      case 'Grade 7':
        return 'class_7';
      case 'Grade 8':
        return 'class_8';
      case 'Grade 9':
        return 'class_9';
      case 'Grade 10':
        return 'class_10';
      case 'Grade 11':
        return 'class_11';
      case 'Grade 12':
        return 'class_12';
      case 'College':
        return 'ug_1st_year';
      case 'College Sophomore':
        return 'ug_2nd_year';
      case 'University':
        return 'ug_1st_year';
      case 'Mathematics':
        return 'mathematics';
      case 'Science':
        return 'computer_science';
      case 'English':
        return 'english';
      case 'History':
        return 'history';
      case 'Geography':
        return 'geography';
      case 'Art':
        return 'arts';
      case 'Music':
        return 'music';
      case 'Sports':
        return 'sports';
      case 'Technology':
        return 'technology';
      case 'Languages':
        return 'languages';
      default:
        return 'other';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImage == null) return _avatarUrl;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final fileName =
          'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, _selectedImage!);

      return Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload avatar if changed
      final avatarUrl = await _uploadAvatar();

      // Update profile
      await Supabase.instance.client
          .from('user_profiles')
          .update({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'bio': _bioController.text.trim(),
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      // Update student data
      await Supabase.instance.client
          .from('students')
          .update({
            'grade_level': _selectedGrade,
            'primary_interest': _selectedInterest,
            'education_board': _selectedBoard,
            'state': _selectedState,
            'city': _selectedCity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: _selectedImage == null && _avatarUrl == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5DADE2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Personal Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value?.trim().isEmpty ?? true) {
                                        return 'First name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value?.trim().isEmpty ?? true) {
                                        return 'Last name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                enabled: false,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _bioController,
                              decoration: const InputDecoration(
                                labelText: 'Bio',
                                border: OutlineInputBorder(),
                                hintText: 'Tell us about yourself...',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Academic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Academic Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // FIXED: Education Level Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedGrade,
                              decoration: const InputDecoration(
                                labelText: 'Education Level',
                                border: OutlineInputBorder(),
                                hintText: 'Select your current education level',
                              ),
                              items: _gradeOptions.map((grade) {
                                return DropdownMenuItem<String>(
                                  value: grade['value'],
                                  child: Text(grade['display']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedGrade = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your education level';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                            const SizedBox(height: 16),

                            // FIXED: Primary Interest Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedInterest,
                              decoration: const InputDecoration(
                                labelText: 'Primary Interest',
                                border: OutlineInputBorder(),
                                hintText:
                                    'Select your primary area of interest',
                              ),
                              items: _interestOptions.map((interest) {
                                return DropdownMenuItem<String>(
                                  value: interest['value'],
                                  child: Text(interest['display']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedInterest = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your primary interest';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                            const SizedBox(height: 16),

                            // Education Board Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedBoard,
                              decoration: const InputDecoration(
                                labelText: 'Education Board',
                                border: OutlineInputBorder(),
                                hintText: 'Select your education board',
                              ),
                              items: _educationBoards.map((board) {
                                return DropdownMenuItem<String>(
                                  value: board['value'],
                                  child: Text(board['display']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedBoard = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your education board';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // State Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedState,
                              decoration: const InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(),
                                hintText: 'Select your state',
                              ),
                              items: _indianStatesAndCities.keys.map((state) {
                                return DropdownMenuItem<String>(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedState = value;
                                  _selectedCity =
                                      null; // Reset city when state changes
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your state';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                            const SizedBox(height: 16),

                            // City Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedCity,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                                hintText: 'Select your city',
                              ),
                              items: _selectedState != null
                                  ? _indianStatesAndCities[_selectedState]!.map(
                                      (city) {
                                        return DropdownMenuItem<String>(
                                          value: city,
                                          child: Text(city),
                                        );
                                      },
                                    ).toList()
                                  : [],
                              onChanged: (value) {
                                setState(() => _selectedCity = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your city';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                          ],
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
