// screens/coaching_center/courses/edit_course_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditCoursePage extends StatefulWidget {
  final Map<String, dynamic> course;

  const EditCoursePage({super.key, required this.course});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxEnrollmentsController = TextEditingController();
  // final _academyController = TextEditingController();
  
  String _selectedCategory = 'programming';
  String _selectedSubcategory = 'web_development';
  String _selectedLevel = 'beginner';
  String _selectedDifficulty = 'Beginner';
  String _selectedLanguage = 'english';
  
  bool _isFree = false;
  bool _isCertified = false;
  bool _isPublished = false;
  bool _isLoading = false;
  
  List<String> _learningOutcomes = [];
  List<String> _prerequisites = [];
  List<String> _requirements = [];
  List<String> _tags = [];
  
  File? _thumbnailImage;
  File? _courseImage;
  String? _currentThumbnailUrl;
  String? _currentImageUrl;
  
  final TextEditingController _learningOutcomeController = TextEditingController();
  final TextEditingController _prerequisiteController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  final List<String> _categories = [
    'programming', 'mathematics', 'science', 'language', 'business', 'design', 'marketing'
  ];
  
  final Map<String, List<String>> _subcategories = {
    'programming': ['web_development', 'mobile_development', 'data_science', 'ai_ml'],
    'mathematics': ['algebra', 'calculus', 'statistics', 'geometry'],
    'science': ['physics', 'chemistry', 'biology', 'computer_science'],
    'language': ['english', 'spanish', 'french', 'german'],
    'business': ['management', 'finance', 'marketing', 'entrepreneurship'],
    'design': ['ui_ux', 'graphic_design', 'web_design', 'product_design'],
    'marketing': ['digital_marketing', 'social_media', 'seo', 'content_marketing']
  };

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final course = widget.course;
    _titleController.text = course['title'] ?? '';
    _descriptionController.text = course['description'] ?? '';
    _priceController.text = course['price']?.toString() ?? '0';
    _originalPriceController.text = course['original_price']?.toString() ?? '';
    _durationController.text = course['duration_hours']?.toString() ?? '0';
    _maxEnrollmentsController.text = course['max_enrollments']?.toString() ?? '';
    _selectedCategory = course['category'] ?? 'programming';
    _selectedSubcategory = course['subcategory'] ?? 'web_development';
    _selectedLevel = course['level'] ?? 'beginner';
    _selectedDifficulty = course['difficulty'] ?? 'Beginner';
    _selectedLanguage = course['language'] ?? 'english';
    
    _isFree = course['is_free'] ?? false;
    _isCertified = course['is_certified'] ?? false;
    _isPublished = course['is_published'] ?? false;
    
    _learningOutcomes = List<String>.from(course['learning_outcomes'] ?? []);
    _prerequisites = List<String>.from(course['prerequisites'] ?? []);
    _requirements = List<String>.from(course['requirements'] ?? []);
    _tags = List<String>.from(course['tags'] ?? []);
    
    _currentThumbnailUrl = course['thumbnail_url'];
    _currentImageUrl = course['image_url'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Course'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveDraft,
            icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
            label: const Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth > 1200 ? 1200 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 32 : 24),
                      _buildBasicInfoSection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildCategorySection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildPricingSection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildMediaSection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildContentSection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      _buildSettingsSection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 40 : 32),
                      _buildActionButtons(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 32 : 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageHeader(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Color(0xFF00B894),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Course',
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 600 ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Update your course information and settings',
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 600 ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BoxConstraints constraints) {
  return _buildSection(
    title: 'Basic Information',
    icon: Icons.info_outline,
    constraints: constraints,
    children: [
      _buildTextField(
        controller: _titleController,
        label: 'Course Title',
        hint: 'Enter course title',
        isRequired: true,
        validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
        constraints: constraints,
      ),
      SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
      _buildTextField(
        controller: _descriptionController,
        label: 'Course Description',
        hint: 'Describe what students will learn',
        maxLines: 4,
        isRequired: true,
        validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
        constraints: constraints,
      ),
      SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
      // Only duration field, remove academy field
      _buildTextField(
        controller: _durationController,
        label: 'Duration (Hours)',
        hint: '0',
        keyboardType: TextInputType.number,
        isRequired: true,
        validator: (value) {
          if (value?.isEmpty == true) return 'Duration is required';
          if (int.tryParse(value!) == null) return 'Enter valid duration';
          return null;
        },
        constraints: constraints,
      ),
    ],
  );
}

// Update the save method to auto-populate academy from coaching center
Future<void> _updateCourse({bool isDraft = false}) async {
  if (!isDraft && !_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw 'Not authenticated';

    // Get coaching center name automatically
    final centerResponse = await Supabase.instance.client
        .from('coaching_centers')
        .select('center_name')
        .eq('id', userId)
        .single();

    String? thumbnailUrl = _currentThumbnailUrl;
    String? imageUrl = _currentImageUrl;
    
    if (_thumbnailImage != null) {
      thumbnailUrl = await _uploadImage(_thumbnailImage!, 'thumbnails');
    }
    
    if (_courseImage != null) {
      imageUrl = await _uploadImage(_courseImage!, 'course-images');
    }

    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'academy': centerResponse['center_name'], // Auto-populate from coaching center
      'category': _selectedCategory,
      'subcategory': _selectedSubcategory,
      'level': _selectedLevel,
      'difficulty': _selectedDifficulty,
      'language': _selectedLanguage,
      'duration_hours': int.tryParse(_durationController.text) ?? 0,
      'price': _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
      'original_price': _originalPriceController.text.isEmpty ? null : double.tryParse(_originalPriceController.text),
      'is_free': _isFree,
      'max_enrollments': _maxEnrollmentsController.text.isEmpty ? null : int.tryParse(_maxEnrollmentsController.text),
      'learning_outcomes': _learningOutcomes,
      'what_you_will_learn': _learningOutcomes,
      'prerequisites': _prerequisites,
      'requirements': _requirements,
      'tags': _tags,
      'is_certified': _isCertified,
      'is_published': isDraft ? false : _isPublished,
      'published_at': isDraft ? null : (_isPublished ? DateTime.now().toIso8601String() : null),
      'thumbnail_url': thumbnailUrl,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await Supabase.instance.client
        .from('courses')
        .update(courseData)
        .eq('id', widget.course['id']);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course ${isDraft ? 'saved as draft' : 'updated'} successfully'),
          backgroundColor: const Color(0xFF00B894),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating course: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  Widget _buildCategorySection(BoxConstraints constraints) {
    return _buildSection(
      title: 'Category & Classification',
      icon: Icons.category_outlined,
      constraints: constraints,
      children: [
        if (constraints.maxWidth > 600)
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown(constraints)),
              const SizedBox(width: 20),
              Expanded(child: _buildSubcategoryDropdown(constraints)),
            ],
          )
        else ...[
          _buildCategoryDropdown(constraints),
          const SizedBox(height: 16),
          _buildSubcategoryDropdown(constraints),
        ],
        SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
        if (constraints.maxWidth > 600)
          Row(
            children: [
              Expanded(child: _buildLevelDropdown(constraints)),
              const SizedBox(width: 20),
              Expanded(child: _buildDifficultyDropdown(constraints)),
            ],
          )
        else ...[
          _buildLevelDropdown(constraints),
          const SizedBox(height: 16),
          _buildDifficultyDropdown(constraints),
        ],
        SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
        _buildLanguageDropdown(constraints),
      ],
    );
  }

  Widget _buildPricingSection(BoxConstraints constraints) {
    return _buildSection(
      title: 'Pricing',
      icon: Icons.attach_money,
      constraints: constraints,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isFree ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFree ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
            ),
          ),
          child: SwitchListTile(
            title: const Text('Free Course', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Make this course available for free'),
            value: _isFree,
            onChanged: (value) => setState(() => _isFree = value),
            activeColor: const Color(0xFF00B894),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (!_isFree) ...[
          SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
          if (constraints.maxWidth > 600)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Course Price (₹)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefixText: '₹ ',
                    isRequired: true,
                    validator: (value) {
                      if (!_isFree && value?.isEmpty == true) return 'Price is required';
                      if (!_isFree && double.tryParse(value!) == null) return 'Enter valid price';
                      return null;
                    },
                    constraints: constraints,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTextField(
                    controller: _originalPriceController,
                    label: 'Original Price (₹)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefixText: '₹ ',
                    constraints: constraints,
                  ),
                ),
              ],
            )
          else ...[
            _buildTextField(
              controller: _priceController,
              label: 'Course Price (₹)',
              hint: '0',
              keyboardType: TextInputType.number,
              prefixText: '₹ ',
              isRequired: true,
              validator: (value) {
                if (!_isFree && value?.isEmpty == true) return 'Price is required';
                if (!_isFree && double.tryParse(value!) == null) return 'Enter valid price';
                return null;
              },
              constraints: constraints,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _originalPriceController,
              label: 'Original Price (₹)',
              hint: '0',
              keyboardType: TextInputType.number,
              prefixText: '₹ ',
              constraints: constraints,
            ),
          ],
        ],
        SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
        _buildTextField(
          controller: _maxEnrollmentsController,
          label: 'Maximum Enrollments',
          hint: 'Leave empty for unlimited',
          keyboardType: TextInputType.number,
          constraints: constraints,
        ),
      ],
    );
  }

  Widget _buildMediaSection(BoxConstraints constraints) {
    return _buildSection(
      title: 'Course Media',
      icon: Icons.image_outlined,
      constraints: constraints,
      children: [
        if (constraints.maxWidth > 600)
          Row(
            children: [
              Expanded(child: _buildImageUpload('Thumbnail', _thumbnailImage, _currentThumbnailUrl, _pickThumbnail, constraints)),
              const SizedBox(width: 20),
              Expanded(child: _buildImageUpload('Course Image', _courseImage, _currentImageUrl, _pickCourseImage, constraints)),
            ],
          )
        else ...[
          _buildImageUpload('Thumbnail', _thumbnailImage, _currentThumbnailUrl, _pickThumbnail, constraints),
          const SizedBox(height: 16),
          _buildImageUpload('Course Image', _courseImage, _currentImageUrl, _pickCourseImage, constraints),
        ],
      ],
    );
  }

  Widget _buildContentSection(BoxConstraints constraints) {
    return _buildSection(
      title: 'Course Content',
      icon: Icons.list_alt_outlined,
      constraints: constraints,
      children: [
        _buildListSection('Learning Outcomes', _learningOutcomes, _learningOutcomeController, _addLearningOutcome, constraints),
        SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
        _buildListSection('Prerequisites', _prerequisites, _prerequisiteController, _addPrerequisite, constraints),
        SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
        _buildListSection('Requirements', _requirements, _requirementController, _addRequirement, constraints),
        SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
        _buildListSection('Tags', _tags, _tagController, _addTag, constraints),
      ],
    );
  }

  Widget _buildSettingsSection(BoxConstraints constraints) {
    return _buildSection(
      title: 'Course Settings',
      icon: Icons.settings_outlined,
      constraints: constraints,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Certified Course', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Provide certificate upon completion'),
                value: _isCertified,
                onChanged: (value) => setState(() => _isCertified = value),
                activeColor: const Color(0xFF00B894),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Published', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Make course visible to students'),
                value: _isPublished,
                onChanged: (value) => setState(() => _isPublished = value),
                activeColor: const Color(0xFF00B894),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BoxConstraints constraints,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required BoxConstraints constraints,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: constraints.maxWidth > 600 ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required BoxConstraints constraints,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: constraints.maxWidth > 600 ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
          ),
          items: items,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BoxConstraints constraints) {
    return _buildDropdown(
      label: 'Category',
      value: _selectedCategory,
      isRequired: true,
      constraints: constraints,
      items: _categories.map((category) => DropdownMenuItem(
        value: category,
        child: Text(
          category.replaceAll('_', ' ').toUpperCase(),
          overflow: TextOverflow.ellipsis,
        ),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
          _selectedSubcategory = _subcategories[value]!.first;
        });
      },
    );
  }

  Widget _buildSubcategoryDropdown(BoxConstraints constraints) {
    return _buildDropdown(
      label: 'Subcategory',
      value: _selectedSubcategory,
      isRequired: true,
      constraints: constraints,
      items: _subcategories[_selectedCategory]!.map((subcategory) => DropdownMenuItem(
        value: subcategory,
        child: Text(
          subcategory.replaceAll('_', ' ').toUpperCase(),
          overflow: TextOverflow.ellipsis,
        ),
      )).toList(),
      onChanged: (value) => setState(() => _selectedSubcategory = value!),
    );
  }

  Widget _buildLevelDropdown(BoxConstraints constraints) {
    return _buildDropdown(
      label: 'Level',
      value: _selectedLevel,
      isRequired: true,
      constraints: constraints,
      items: const [
        DropdownMenuItem(value: 'beginner', child: Text('BEGINNER')),
        DropdownMenuItem(value: 'intermediate', child: Text('INTERMEDIATE')),
        DropdownMenuItem(value: 'advanced', child: Text('ADVANCED')),
      ],
      onChanged: (value) => setState(() => _selectedLevel = value!),
    );
  }

  Widget _buildDifficultyDropdown(BoxConstraints constraints) {
    return _buildDropdown(
      label: 'Difficulty',
      value: _selectedDifficulty,
      isRequired: true,
      constraints: constraints,
      items: const [
        DropdownMenuItem(value: 'Beginner', child: Text('BEGINNER')),
        DropdownMenuItem(value: 'Intermediate', child: Text('INTERMEDIATE')),
        DropdownMenuItem(value: 'Advanced', child: Text('ADVANCED')),
      ],
      onChanged: (value) => setState(() => _selectedDifficulty = value!),
    );
  }

  Widget _buildLanguageDropdown(BoxConstraints constraints) {
    return _buildDropdown(
      label: 'Language',
      value: _selectedLanguage,
      isRequired: true,
      constraints: constraints,
      items: const [
        DropdownMenuItem(value: 'english', child: Text('ENGLISH')),
        DropdownMenuItem(value: 'hindi', child: Text('HINDI')),
        DropdownMenuItem(value: 'spanish', child: Text('SPANISH')),
        DropdownMenuItem(value: 'french', child: Text('FRENCH')),
      ],
      onChanged: (value) => setState(() => _selectedLanguage = value!),
    );
  }

  Widget _buildImageUpload(String label, File? image, String? currentUrl, VoidCallback onTap, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: constraints.maxWidth > 600 ? 150 : 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(image, fit: BoxFit.cover),
                )
              : currentUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(currentUrl, fit: BoxFit.cover),
                    )
                  : InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Upload $label',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG up to 5MB',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
        ),
        if (image != null || currentUrl != null) ...[
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Change'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, TextEditingController controller, VoidCallback onAdd, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add ${title.toLowerCase()}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Chip(
              label: Text(item),
              onDeleted: () => setState(() => items.remove(item)),
              deleteIcon: const Icon(Icons.close, size: 18),
              backgroundColor: const Color(0xFF00B894).withOpacity(0.1),
              labelStyle: const TextStyle(color: Color(0xFF00B894)),
              deleteIconColor: const Color(0xFF00B894),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: constraints.maxWidth > 600
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Update Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Update Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }

  void _addLearningOutcome() {
    if (_learningOutcomeController.text.isNotEmpty) {
      setState(() {
        _learningOutcomes.add(_learningOutcomeController.text);
        _learningOutcomeController.clear();
      });
    }
  }

  void _addPrerequisite() {
    if (_prerequisiteController.text.isNotEmpty) {
      setState(() {
        _prerequisites.add(_prerequisiteController.text);
        _prerequisiteController.clear();
      });
    }
  }

  void _addRequirement() {
    if (_requirementController.text.isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text);
        _requirementController.clear();
      });
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _thumbnailImage = File(image.path);
      });
    }
  }

  Future<void> _pickCourseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _courseImage = File(image.path);
      });
    }
  }

  Future<void> _saveDraft() async {
    await _updateCourse(isDraft: true);
  }


  Future<String> _uploadImage(File image, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
    await Supabase.instance.client.storage
        .from('course-media')
        .upload('$folder/$fileName', image);
    
    return Supabase.instance.client.storage
        .from('course-media')
        .getPublicUrl('$folder/$fileName');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _durationController.dispose();
    _maxEnrollmentsController.dispose();
    _learningOutcomeController.dispose();
    _prerequisiteController.dispose();
    _requirementController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
