// lib/screens/student/settings/widgets/profile_edit_form.dart
import 'package:brainboosters_app/screens/student/profile/profile_repository.dart';
import 'package:brainboosters_app/screens/student/profile/widgets/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditForm extends StatefulWidget {
  final ProfileData profileData;
  final VoidCallback onProfileUpdated;

  const ProfileEditForm({
    super.key,
    required this.profileData,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolController;
  String? _selectedGender;
  String? _selectedGradeLevel;
  bool _isLoading = false;

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
    final userProfile = widget.profileData.userProfile!;
    final student = widget.profileData.student;

    _firstNameController = TextEditingController(
      text: userProfile['first_name'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: userProfile['last_name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: userProfile['phone'] ?? '',
    );
    _schoolController = TextEditingController(
      text: student?['school_name'] ?? '',
    );
    _selectedGender = userProfile['gender'];

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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Picture Section
          _buildProfilePictureSection(),
          const SizedBox(height: 32),

          // Personal Information Section
          _buildPersonalInformationSection(),
          const SizedBox(height: 32),

          // Academic Information Section
          _buildAcademicInformationSection(),
          const SizedBox(height: 32),

          // Save Button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: widget.profileData.avatarUrl != null
                ? NetworkImage(widget.profileData.avatarUrl!)
                : null,
            child: widget.profileData.avatarUrl == null
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

        // Education level dropdown
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
        final student = widget.profileData.student;
        if (student != null) {
          await Supabase.instance.client
              .from('students')
              .update({
                'school_name': _schoolController.text.trim(),
                'grade_level': _selectedGradeLevel,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', student['id']);
        }

        if (mounted) {
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
}
