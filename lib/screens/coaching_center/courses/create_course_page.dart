// screens/coaching_center/courses/create_course_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/course_basic_info_section.dart';
import 'widgets/course_category_section.dart';
import 'widgets/course_pricing_section.dart';
import 'widgets/course_media_section.dart';
import 'widgets/course_content_section.dart';
import 'widgets/course_settings_section.dart';
import 'widgets/course_action_buttons.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final CourseFormData _formData = CourseFormData();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _saveCourse(isDraft: true),
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
              CourseBasicInfoSection(formData: _formData),
              const SizedBox(height: 24),
              CourseCategorySection(formData: _formData),
              const SizedBox(height: 24),
              CoursePricingSection(formData: _formData),
              const SizedBox(height: 24),
              CourseMediaSection(formData: _formData),
              const SizedBox(height: 24),
              CourseContentSection(formData: _formData),
              const SizedBox(height: 24),
              CourseSettingsSection(formData: _formData),
              const SizedBox(height: 32),
              CourseActionButtons(
                isLoading: _isLoading,
                onCancel: () => Navigator.pop(context),
                onCreate: () => _saveCourse(isDraft: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCourse({bool isDraft = false}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'Not authenticated';

      // Upload media files
      String? courseImageUrl;
      String? introVideoUrl;

      if (_formData.courseImage != null) {
        courseImageUrl = await _uploadFile(_formData.courseImage!, 'images');
      }

      if (_formData.introVideo != null) {
        introVideoUrl = await _uploadFile(_formData.introVideo!, 'videos');
      }

      final courseData = {
        'course_id': 'COURSE_${DateTime.now().millisecondsSinceEpoch}',
        'slug': _formData.titleController.text.toLowerCase().replaceAll(
          ' ',
          '-',
        ),
        'title': _formData.titleController.text.trim(),
        'description': _formData.descriptionController.text.trim(),
        'category': _formData.selectedCategory,
        'subcategory': _formData.selectedSubcategory,
        'level': _formData.selectedLevel,
        'difficulty': _formData.selectedDifficulty,
        'language': _formData.selectedLanguage,
        'duration_hours': int.tryParse(_formData.durationController.text) ?? 0,
        'price': _formData.isFree
            ? 0.0
            : double.tryParse(_formData.priceController.text) ?? 0.0,
        'original_price': _formData.originalPriceController.text.isEmpty
            ? null
            : double.tryParse(_formData.originalPriceController.text),
        'is_free': _formData.isFree,
        'max_enrollments': _formData.maxEnrollmentsController.text.isEmpty
            ? null
            : int.tryParse(_formData.maxEnrollmentsController.text),
        'instructor_id': userId,
        'instructor_type': 'coaching_center',
        'learning_outcomes': _formData.learningOutcomes,
        'what_you_will_learn': _formData.learningOutcomes,
        'prerequisites': _formData.prerequisites,
        'requirements': _formData.requirements,
        'tags': _formData.tags,
        'is_certified': _formData.isCertified,
        'is_published': isDraft ? false : _formData.isPublished,
        'published_at': isDraft
            ? null
            : (_formData.isPublished ? DateTime.now().toIso8601String() : null),
        'course_image_url': courseImageUrl,
        'intro_video_url': introVideoUrl,
      };

      final response = await Supabase.instance.client
          .from('courses')
          .insert(courseData)
          .select()
          .single();

      // Create course features
      await Supabase.instance.client.from('course_features').insert({
        'course_id': response['id'],
        'certificate': _formData.isCertified,
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

  Future<String> _uploadFile(dynamic file, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    await Supabase.instance.client.storage
        .from('course-media')
        .upload('$folder/$fileName', file);

    return Supabase.instance.client.storage
        .from('course-media')
        .getPublicUrl('$folder/$fileName');
  }
}

// Data class to hold form data
class CourseFormData {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final originalPriceController = TextEditingController();
  final durationController = TextEditingController();
  final maxEnrollmentsController = TextEditingController();

  String selectedCategory = 'programming';
  String selectedSubcategory = 'web_development';
  String selectedLevel = 'beginner';
  String selectedDifficulty = 'Beginner';
  String selectedLanguage = 'english';

  bool isFree = false;
  bool isCertified = false;
  bool isPublished = false;

  List<String> learningOutcomes = [];
  List<String> prerequisites = [];
  List<String> requirements = [];
  List<String> tags = [];

  dynamic courseImage;
  dynamic introVideo;

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    durationController.dispose();
    maxEnrollmentsController.dispose();
  }
}
