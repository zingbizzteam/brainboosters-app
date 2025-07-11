import 'package:flutter/material.dart';
import '../profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditWidget extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final VoidCallback onProfileUpdated;

  const ProfileEditWidget({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileEditWidget> createState() => _ProfileEditWidgetState();
}

class _ProfileEditWidgetState extends State<ProfileEditWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolController;
  String? _selectedGender;
  String? _selectedGradeLevel;
  bool _isLoading = false;

  // FIXED: Complete education levels including college
  static const List<Map<String, String>> _educationLevels = [
    {'value': '1', 'label': 'Grade 1'},
    {'value': '2', 'label': 'Grade 2'},
    {'value': '3', 'label': 'Grade 3'},
    {'value': '4', 'label': 'Grade 4'},
    {'value': '5', 'label': 'Grade 5'},
    {'value': '6', 'label': 'Grade 6'},
    {'value': '7', 'label': 'Grade 7'},
    {'value': '8', 'label': 'Grade 8'},
    {'value': '9', 'label': 'Grade 9'},
    {'value': '10', 'label': 'Grade 10'},
    {'value': '11', 'label': 'Grade 11'},
    {'value': '12', 'label': 'Grade 12'},
    {'value': 'College Freshman', 'label': 'College Freshman'},
    {'value': 'College Sophomore', 'label': 'College Sophomore'},
    {'value': 'College Junior', 'label': 'College Junior'},
    {'value': 'College Senior', 'label': 'College Senior'},
    {'value': 'Graduate Student', 'label': 'Graduate Student'},
    {'value': 'PhD Student', 'label': 'PhD Student'},
    {'value': 'Other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final student = widget.userProfile['students'] as Map<String, dynamic>?;
    _firstNameController = TextEditingController(
      text: widget.userProfile['first_name'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userProfile['last_name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userProfile['phone'] ?? '',
    );
    _schoolController = TextEditingController(
      text: student?['school_name'] ?? '',
    );
    _selectedGender = widget.userProfile['gender'];
    
    // FIXED: Validate grade level exists in our list
    final currentGradeLevel = student?['grade_level']?.toString();
    _selectedGradeLevel = _educationLevels.any((level) => level['value'] == currentGradeLevel) 
        ? currentGradeLevel 
        : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // FIXED: Constraint-aware layout that prevents overflow
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32, // Account for padding
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(),
                    SizedBox(height: _getAdaptiveSpacing(constraints.maxHeight, 32)),
                    
                    // Personal Information Section
                    _buildPersonalInformationSection(),
                    SizedBox(height: _getAdaptiveSpacing(constraints.maxHeight, 32)),
                    
                    // Academic Information Section
                    _buildAcademicInformationSection(),
                    SizedBox(height: _getAdaptiveSpacing(constraints.maxHeight, 32)),
                    
                    // Save Button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // FIXED: Adaptive spacing based on screen height
  double _getAdaptiveSpacing(double screenHeight, double baseSpacing) {
    if (screenHeight < 600) return baseSpacing * 0.5; // Compact screens
    if (screenHeight < 800) return baseSpacing * 0.75; // Medium screens
    return baseSpacing; // Large screens
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: widget.userProfile['avatar_url'] != null
                ? NetworkImage(widget.userProfile['avatar_url'])
                : null,
            child: widget.userProfile['avatar_url'] == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: _changeProfilePicture,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        const SizedBox(height: 16),
        
        // Name fields
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop/Tablet layout
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
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
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              );
            } else {
              // Mobile layout
              return Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Phone field
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // Gender dropdown
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAcademicInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Academic Information'),
        const SizedBox(height: 16),
        
        // School name
        TextFormField(
          controller: _schoolController,
          decoration: const InputDecoration(
            labelText: 'School/Institution Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
        ),
        const SizedBox(height: 16),
        
        // FIXED: Education level dropdown with all levels
        DropdownButtonFormField<String>(
          value: _selectedGradeLevel,
          decoration: const InputDecoration(
            labelText: 'Education Level',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.grade),
          ),
          items: _educationLevels.map((level) {
            return DropdownMenuItem<String>(
              value: level['value'],
              child: Text(level['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGradeLevel = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your education level';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  void _changeProfilePicture() {
    // Implement profile picture change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture upload feature coming soon!'),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update user profile
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final success = await ProfileRepository.updateUserProfile(profileData);

      if (success) {
        // Update student data if exists
        final student = widget.userProfile['students'] as Map<String, dynamic>?;
        if (student != null) {
          await _supabase
              .from('students')
              .update({
                'school_name': _schoolController.text.trim(),
                'grade_level': _selectedGradeLevel,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', student['id']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onProfileUpdated();
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static final _supabase = Supabase.instance.client;
}
