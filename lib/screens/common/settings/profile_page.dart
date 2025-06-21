// screens/Student/settings/profile_page.dart
import 'package:brainboosters_app/screens/common/settings/widgets/course_selection_widgets.dart';
import 'package:brainboosters_app/screens/common/settings/widgets/language_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late String _selectedLanguage;

  bool _isLoading = true;
  bool _isUpdating = false;
  String? _avatarUrl;
  String? _email;
  DateTime? _dateOfBirth;
  File? _imageFile;
  List<String> _selectedCourses = []; // Added for course selection

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onLanguageChanged(String? language) {
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _email = user.email;
          _nameController.text =
              response?['name'] ?? user.userMetadata?['full_name'] ?? '';
          _phoneController.text = response?['phone'] ?? '';
          _selectedLanguage = response?['language'] ?? 'English';
          _avatarUrl =
              response?['avatar_url'] ?? user.userMetadata?['avatar_url'];

          // Load selected courses
          if (response?['selected_courses'] != null) {
            _selectedCourses = List<String>.from(response?['selected_courses']);
          }

          if (response?['date_of_birth'] != null) {
            _dateOfBirth = DateTime.parse(response?['date_of_birth']);
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error loading profile: $e');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? uploadedAvatarUrl = _avatarUrl;

      if (_imageFile != null) {
        uploadedAvatarUrl = await _uploadAvatar(_imageFile!, user.id);
      }

      final updateData = {
        'id': user.id,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'language': _selectedLanguage,
        'avatar_url': uploadedAvatarUrl,
        'selected_courses': _selectedCourses, // Include selected courses
      };

      if (_dateOfBirth != null) {
        updateData['date_of_birth'] = _dateOfBirth!.toIso8601String().split(
          'T',
        )[0];
      }

      await Supabase.instance.client.from('profiles').upsert(updateData);

      if (_nameController.text.trim().isNotEmpty) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'full_name': _nameController.text.trim()}),
        );
      }

      if (mounted) {
        setState(() {
          _avatarUrl = uploadedAvatarUrl;
          _imageFile = null;
        });
        _showSuccessSnackBar('Profile updated successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<String?> _uploadAvatar(File imageFile, String userId) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          'avatar_$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, imageFile);

      return Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _navigateToCourseSelection() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) =>
            CourseSelectionPage(initialSelectedCourses: _selectedCourses),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCourses = result;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFFF9FBFD),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4AA0E6)),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF4AA0E6),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF9FBFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4AA0E6)),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _updateProfile,
            child: _isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Color(0xFF4AA0E6)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                        ? NetworkImage(_avatarUrl!)
                                        : null)
                                    as ImageProvider?,
                          backgroundColor: Colors.grey[300],
                          child:
                              (_avatarUrl == null || _avatarUrl!.isEmpty) &&
                                  _imageFile == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Your Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_email != null)
                      Text(
                        _email!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form Fields
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[\d\s-()]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select Date of Birth',
                    style: TextStyle(
                      color: _dateOfBirth != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              LanguageStepWidget(
                selectedLanguage: _selectedLanguage,
                onChanged: _onLanguageChanged,
              ),

              const SizedBox(height: 32),

              // Course Selection Section
              _buildSectionTitle('Learning Preferences'),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Courses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _navigateToCourseSelection,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4AA0E6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedCourses.isEmpty)
                      const Text(
                        'No courses selected yet. Tap "Edit" to choose your learning goals.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedCourses.map((course) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[300]!),
                            ),
                            child: Text(
                              course,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Account Information (Read-only)
              _buildSectionTitle('Account Information'),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _email ?? 'Not available',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUpdating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Updating...'),
                          ],
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
