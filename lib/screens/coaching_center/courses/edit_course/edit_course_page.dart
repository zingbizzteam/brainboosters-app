// screens/coaching_center/courses/edit_course_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'widgets/edit_course_basic_info.dart';
import 'widgets/edit_course_category_section.dart';
import 'widgets/edit_course_pricing_section.dart';
import 'widgets/edit_course_media_section.dart';
import 'widgets/rich_text_editor_widget.dart';
import 'widgets/enhanced_tags_widget.dart';
import 'widgets/edit_course_settings_section.dart';
import 'widgets/edit_course_action_buttons.dart';

class EditCoursePage extends StatefulWidget {
  final Map course;

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

  File? _courseImage;
  File? _introVideo;
  String? _currentImageUrl;
  String? _currentVideoUrl;

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

    _currentImageUrl = course['course_image_url'];
    _currentVideoUrl = course['intro_video_url'];
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
                      // Basic Information Section
                      EditCourseBasicInfo(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        durationController: _durationController,
                        selectedLanguage: _selectedLanguage,
                        onLanguageChanged: (value) => setState(() => _selectedLanguage = value),
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      
                      // Category Section
                      EditCourseCategorySection(
                        selectedCategory: _selectedCategory,
                        selectedSubcategory: _selectedSubcategory,
                        selectedLevel: _selectedLevel,
                        selectedDifficulty: _selectedDifficulty,
                        onCategoryChanged: (category, subcategory) => setState(() {
                          _selectedCategory = category;
                          _selectedSubcategory = subcategory;
                        }),
                        onLevelChanged: (value) => setState(() => _selectedLevel = value),
                        onDifficultyChanged: (value) => setState(() => _selectedDifficulty = value),
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      
                      // Pricing Section
                      EditCoursePricingSection(
                        priceController: _priceController,
                        originalPriceController: _originalPriceController,
                        maxEnrollmentsController: _maxEnrollmentsController,
                        isFree: _isFree,
                        onFreeChanged: (value) => setState(() => _isFree = value),
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      
                      // Media Section
                      EditCourseMediaSection(
                        courseImage: _courseImage,
                        introVideo: _introVideo,
                        currentImageUrl: _currentImageUrl,
                        currentVideoUrl: _currentVideoUrl,
                        onImagePicked: (image) => setState(() => _courseImage = image),
                        onVideoPicked: (video) => setState(() => _introVideo = video),
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      
                      // Rich Text Content Section
                      _buildContentSection(constraints),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      
                      // Enhanced Tags Section
                      EnhancedTagsWidget(
                        tags: _tags,
                        onChanged: (tags) => setState(() => _tags = tags),
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                      
                      // Settings Section
                      EditCourseSettingsSection(
                        isCertified: _isCertified,
                        isPublished: _isPublished,
                        onCertifiedChanged: (value) => setState(() => _isCertified = value),
                        onPublishedChanged: (value) => setState(() => _isPublished = value),
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxWidth > 600 ? 40 : 32),
                      
                      // Action Buttons
                      EditCourseActionButtons(
                        isLoading: _isLoading,
                        onCancel: () => Navigator.pop(context),
                        onUpdate: _updateCourse,
                        constraints: constraints,
                      ),
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

  Widget _buildContentSection(BoxConstraints constraints) {
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
                  child: const Icon(Icons.list_alt_outlined, color: Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Course Content',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
            
            RichTextEditorWidget(
              label: 'Learning Outcomes',
              items: _learningOutcomes,
              onChanged: (items) => setState(() => _learningOutcomes = items),
              constraints: constraints,
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 32 : 24),
            
            RichTextEditorWidget(
              label: 'Prerequisites',
              items: _prerequisites,
              onChanged: (items) => setState(() => _prerequisites = items),
              constraints: constraints,
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 32 : 24),
            
            RichTextEditorWidget(
              label: 'Requirements',
              items: _requirements,
              onChanged: (items) => setState(() => _requirements = items),
              constraints: constraints,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCourse({bool isDraft = false}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'Not authenticated';

      final centerResponse = await Supabase.instance.client
          .from('coaching_centers')
          .select('center_name')
          .eq('id', userId)
          .single();

      String? imageUrl = _currentImageUrl;
      String? videoUrl = _currentVideoUrl;

      final courseId = widget.course['course_id'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';

      if (_courseImage != null) {
        imageUrl = await _uploadFile(_courseImage!, 'images', courseId);
      }

      if (_introVideo != null) {
        videoUrl = await _uploadFile(_introVideo!, 'videos', courseId);
      }

      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'academy': centerResponse['center_name'],
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
        'course_image_url': imageUrl,
        'intro_video_url': videoUrl,
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

  Future<String> _uploadFile(File file, String folder, String courseId) async {
    final fileExtension = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    String fileName;
    String folderPath;
    
    if (folder == 'images') {
      folderPath = 'courses/$courseId/images';
      fileName = 'course_image_${timestamp}.$fileExtension';
    } else if (folder == 'videos') {
      folderPath = 'courses/$courseId/videos';
      fileName = 'intro_video_${timestamp}.$fileExtension';
    } else {
      folderPath = 'courses/$courseId/misc';
      fileName = 'file_${timestamp}.$fileExtension';
    }
    
    final fullPath = '$folderPath/$fileName';
    
    try {
      await Supabase.instance.client.storage
          .from('course-media')
          .upload(fullPath, file);

      return Supabase.instance.client.storage
          .from('course-media')
          .getPublicUrl(fullPath);
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  Future<void> _saveDraft() async {
    await _updateCourse(isDraft: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _durationController.dispose();
    _maxEnrollmentsController.dispose();
    super.dispose();
  }
}
