// screens/coaching_center/courses/create_course_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxEnrollmentsController = TextEditingController();
  final _academyController = TextEditingController();

  String _selectedCategory = 'programming';
  String _selectedSubcategory = 'web_development';
  String _selectedSubject = 'flutter';
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
  List<String> _instructors = [];

  File? _thumbnailImage;
  File? _courseImage;

  final TextEditingController _learningOutcomeController =
      TextEditingController();
  final TextEditingController _prerequisiteController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  final List<String> _categories = [
    'programming',
    'mathematics',
    'science',
    'language',
    'business',
    'design',
    'marketing',
  ];

  final Map<String, List<String>> _subcategories = {
    'programming': [
      'web_development',
      'mobile_development',
      'data_science',
      'ai_ml',
    ],
    'mathematics': ['algebra', 'calculus', 'statistics', 'geometry'],
    'science': ['physics', 'chemistry', 'biology', 'computer_science'],
    'language': ['english', 'spanish', 'french', 'german'],
    'business': ['management', 'finance', 'marketing', 'entrepreneurship'],
    'design': ['ui_ux', 'graphic_design', 'web_design', 'product_design'],
    'marketing': [
      'digital_marketing',
      'social_media',
      'seo',
      'content_marketing',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildPricingSection(),
              const SizedBox(height: 24),
              _buildMediaSection(),
              const SizedBox(height: 24),
              _buildLearningOutcomesSection(),
              const SizedBox(height: 24),
              _buildPrerequisitesSection(),
              const SizedBox(height: 24),
              _buildRequirementsSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildSettingsSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Course Description *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Description is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _academyController,
              decoration: const InputDecoration(
                labelText: 'Academy/Institution Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (Hours) *',
                border: OutlineInputBorder(),
                suffixText: 'hrs',
              ),
              validator: (value) {
                if (value?.isEmpty == true) return 'Duration is required';
                if (int.tryParse(value!) == null) return 'Enter valid duration';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category & Classification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Category Selection
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(child: _buildCategoryDropdownField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSubcategoryDropdownField()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCategoryDropdownField(),
                      const SizedBox(height: 16),
                      _buildSubcategoryDropdownField(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Level and Difficulty Selection
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(child: _buildLevelDropdownField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDifficultyDropdownField()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLevelDropdownField(),
                      const SizedBox(height: 16),
                      _buildDifficultyDropdownField(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),
            _buildLanguageDropdownField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: _categories
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(
                category.replaceAll('_', ' ').toUpperCase(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
          // Reset subcategory when category changes
          _selectedSubcategory =
              _subcategories[value]?.first ?? 'web_development';
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildSubcategoryDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedSubcategory,
      decoration: const InputDecoration(
        labelText: 'Subcategory *',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: (_subcategories[_selectedCategory] ?? [])
          .map(
            (subcategory) => DropdownMenuItem(
              value: subcategory,
              child: Text(
                subcategory.replaceAll('_', ' ').toUpperCase(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedSubcategory = value!),
      validator: (value) =>
          value == null ? 'Please select a subcategory' : null,
    );
  }

  Widget _buildLevelDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedLevel,
      decoration: const InputDecoration(
        labelText: 'Level *',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: 'beginner', child: Text('BEGINNER')),
        DropdownMenuItem(value: 'intermediate', child: Text('INTERMEDIATE')),
        DropdownMenuItem(value: 'advanced', child: Text('ADVANCED')),
      ],
      onChanged: (value) => setState(() => _selectedLevel = value!),
      validator: (value) => value == null ? 'Please select a level' : null,
    );
  }

  Widget _buildDifficultyDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      decoration: const InputDecoration(
        labelText: 'Difficulty *',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: 'Beginner', child: Text('BEGINNER')),
        DropdownMenuItem(value: 'Intermediate', child: Text('INTERMEDIATE')),
        DropdownMenuItem(value: 'Advanced', child: Text('ADVANCED')),
      ],
      onChanged: (value) => setState(() => _selectedDifficulty = value!),
      validator: (value) => value == null ? 'Please select difficulty' : null,
    );
  }

  Widget _buildLanguageDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      decoration: const InputDecoration(
        labelText: 'Language *',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: 'english', child: Text('ENGLISH')),
        DropdownMenuItem(value: 'hindi', child: Text('HINDI')),
        DropdownMenuItem(value: 'spanish', child: Text('SPANISH')),
        DropdownMenuItem(value: 'french', child: Text('FRENCH')),
      ],
      onChanged: (value) => setState(() => _selectedLanguage = value!),
      validator: (value) => value == null ? 'Please select a language' : null,
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Free Course'),
              subtitle: const Text('Make this course available for free'),
              value: _isFree,
              onChanged: (value) => setState(() => _isFree = value),
              activeColor: const Color(0xFF00B894),
            ),
            if (!_isFree) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Course Price (₹) *',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      validator: (value) {
                        if (!_isFree && value?.isEmpty == true)
                          return 'Price is required';
                        if (!_isFree && double.tryParse(value!) == null)
                          return 'Enter valid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Original Price (₹)',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxEnrollmentsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maximum Enrollments (Optional)',
                border: OutlineInputBorder(),
                helperText: 'Leave empty for unlimited enrollments',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _thumbnailImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _thumbnailImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text('Course Thumbnail'),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickThumbnail,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Thumbnail'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _courseImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _courseImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text('Course Image'),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickCourseImage,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Image'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningOutcomesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Outcomes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _learningOutcomeController,
                    decoration: const InputDecoration(
                      labelText: 'Add learning outcome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addLearningOutcome,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _learningOutcomes
                  .map(
                    (outcome) => Chip(
                      label: Text(outcome),
                      onDeleted: () =>
                          setState(() => _learningOutcomes.remove(outcome)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrerequisitesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prerequisites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prerequisiteController,
                    decoration: const InputDecoration(
                      labelText: 'Add prerequisite',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addPrerequisite,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _prerequisites
                  .map(
                    (prerequisite) => Chip(
                      label: Text(prerequisite),
                      onDeleted: () =>
                          setState(() => _prerequisites.remove(prerequisite)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _requirementController,
                    decoration: const InputDecoration(
                      labelText: 'Add requirement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addRequirement,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _requirements
                  .map(
                    (requirement) => Chip(
                      label: Text(requirement),
                      onDeleted: () =>
                          setState(() => _requirements.remove(requirement)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTag, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Certified Course'),
              subtitle: const Text('Provide certificate upon completion'),
              value: _isCertified,
              onChanged: (value) => setState(() => _isCertified = value),
              activeColor: const Color(0xFF00B894),
            ),
            SwitchListTile(
              title: const Text('Publish Immediately'),
              subtitle: const Text('Make course visible to students'),
              value: _isPublished,
              onChanged: (value) => setState(() => _isPublished = value),
              activeColor: const Color(0xFF00B894),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Create Course'),
          ),
        ),
      ],
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
    await _createCourse(isDraft: true);
  }

  Future<void> _createCourse({bool isDraft = false}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'Not authenticated';

      // Generate unique course ID and slug
      final courseId = 'COURSE_${DateTime.now().millisecondsSinceEpoch}';
      final slug = _titleController.text.toLowerCase().replaceAll(' ', '-');

      // Upload images if selected
      String? thumbnailUrl;
      String? imageUrl;

      if (_thumbnailImage != null) {
        thumbnailUrl = await _uploadImage(_thumbnailImage!, 'thumbnails');
      }

      if (_courseImage != null) {
        imageUrl = await _uploadImage(_courseImage!, 'course-images');
      }

      final courseData = {
        'course_id': courseId,
        'slug': slug,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'academy': _academyController.text.trim().isEmpty
            ? null
            : _academyController.text.trim(),
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'subject': _selectedSubject,
        'level': _selectedLevel,
        'difficulty': _selectedDifficulty,
        'language': _selectedLanguage,
        'duration_hours': int.tryParse(_durationController.text) ?? 0,
        'price': _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
        'original_price': _originalPriceController.text.isEmpty
            ? null
            : double.tryParse(_originalPriceController.text),
        'is_free': _isFree,
        'max_enrollments': _maxEnrollmentsController.text.isEmpty
            ? null
            : int.tryParse(_maxEnrollmentsController.text),
        'instructor_id': userId,
        'instructor_type': 'coaching_center',
        'learning_outcomes': _learningOutcomes,
        'what_you_will_learn': _learningOutcomes,
        'prerequisites': _prerequisites,
        'requirements': _requirements,
        'tags': _tags,
        'is_certified': _isCertified,
        'is_published': isDraft ? false : _isPublished,
        'published_at': isDraft
            ? null
            : (_isPublished ? DateTime.now().toIso8601String() : null),
        'thumbnail_url': thumbnailUrl,
        'image_url': imageUrl,
      };

      final response = await Supabase.instance.client
          .from('courses')
          .insert(courseData)
          .select()
          .single();

      // Create course features
      await Supabase.instance.client.from('course_features').insert({
        'course_id': response['id'],
        'certificate': _isCertified,
        'lifetime_access': true,
        'access_on_mobile': true,
        'instructor_qna': true,
      });

      // Create course analytics
      await Supabase.instance.client.from('course_analytics').insert({
        'course_id': response['id'],
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Course ${isDraft ? 'saved as draft' : 'created'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating course: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImage(File image, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
    final response = await Supabase.instance.client.storage
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
    _academyController.dispose();
    _learningOutcomeController.dispose();
    _prerequisiteController.dispose();
    _requirementController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
