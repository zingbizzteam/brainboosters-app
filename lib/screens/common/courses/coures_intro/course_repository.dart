// lib/screen/common/courses/courses_intro/course_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class CourseRepository {
  static final SupabaseClient _client = Supabase.instance.client;
  static String? get currentUserId => _client.auth.currentUser?.id;
  static bool get isAuthenticated => _client.auth.currentUser != null;

  // FIXED: Handle missing chapters/lessons gracefully and create placeholders
  static Future<Map<String, dynamic>?> getCourseById(String courseId) async {
    try {
      final userId = currentUserId;
      final courseResponse = await _client
          .from('courses')
          .select('''
          id,
          title,
          slug,
          description,
          short_description,
          thumbnail_url,
          trailer_video_url,
          about,
          what_you_learn,
          course_includes,
          target_audience,
          course_requirements,
          category,
          subcategory,
          level,
          language,
          price,
          original_price,
          currency,
          duration_hours,
          total_lessons,
          total_chapters,
          prerequisites,
          learning_outcomes,
          tags,
          rating,
          total_reviews,
          enrollment_count,
          completion_rate,
          last_updated,
          published_at,
          coaching_centers(center_name),
          course_teachers(
            role,
            is_primary,
            teachers(
              id,
              user_profiles(first_name, last_name, avatar_url)
            )
          ),
          chapters(
            id,
            title,
            description,
            chapter_number,
            duration_minutes,
            total_lessons,
            is_published,
            is_free,
            lessons(
              id,
              title,
              description,
              lesson_number,
              lesson_type,
              video_duration,
              is_published,
              is_free
            )
          )
        ''')
          .eq('id', courseId)
          .eq('is_published', true)
          .order('chapter_number', referencedTable: 'chapters')
          .order('lesson_number', referencedTable: 'chapters.lessons')
          .maybeSingle();

      if (courseResponse == null) {
        print('Course not found with ID: $courseId');
        return null;
      }

      // Check enrollment status
      Map<String, dynamic>? enrollmentData;
      if (userId != null) {
        final studentResponse = await _client
            .from('students')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (studentResponse != null) {
          final studentId = studentResponse['id'];
          final enrollmentResponse = await _client
              .from('course_enrollments')
              .select('''
              progress_percentage,
              total_time_spent,
              lessons_completed,
              total_lessons_in_course,
              last_accessed_at,
              enrolled_at,
              completed_at,
              is_active
            ''')
              .eq('course_id', courseId)
              .eq('student_id', studentId)
              .eq('is_active', true)
              .maybeSingle();

          if (enrollmentResponse != null) {
            enrollmentData = enrollmentResponse;
          }
        }
      }

      final result = Map<String, dynamic>.from(courseResponse);
      if (enrollmentData != null) {
        result['enrollment'] = enrollmentData;
      }

      return result;
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }

  // Helper methods for generating meaningful chapter/lesson titles
  static String _getChapterTitle(int chapterIndex) {
    final titles = [
      'Getting Started',
      'Core Concepts',
      'Advanced Topics',
      'Practical Applications',
      'Final Projects',
    ];
    return chapterIndex < titles.length
        ? titles[chapterIndex]
        : 'Chapter ${chapterIndex + 1}';
  }

  static String _getLessonTitle(int chapterIndex, int lessonNumber) {
    final lessonTitles = {
      0: ['Introduction', 'Setup', 'Basic Concepts', 'First Steps', 'Overview'],
      1: [
        'Fundamentals',
        'Key Principles',
        'Core Features',
        'Best Practices',
        'Implementation',
      ],
      2: [
        'Advanced Techniques',
        'Complex Scenarios',
        'Optimization',
        'Performance',
        'Debugging',
      ],
      3: [
        'Real-world Examples',
        'Case Studies',
        'Integration',
        'Deployment',
        'Testing',
      ],
      4: [
        'Final Project',
        'Portfolio Building',
        'Presentation',
        'Review',
        'Next Steps',
      ],
    };

    final titles = lessonTitles[chapterIndex] ?? ['Lesson Content'];
    final titleIndex = (lessonNumber - 1) % titles.length;
    return titles[titleIndex];
  }

  // Get course reviews
  static Future<List<Map<String, dynamic>>> getCourseReviews(
    String courseId,
  ) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            id,
            rating,
            review_text,
            pros,
            cons,
            is_verified_purchase,
            helpful_votes_count,
            not_helpful_votes_count,
            created_at,
            updated_at,
            students!inner(
              id,
              user_profiles!inner(first_name, last_name, avatar_url)
            )
          ''')
          .eq('course_id', courseId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // Enrollment method
  static Future<bool> enrollInCourse(String courseId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final studentResponse = await _client
          .from('students')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (studentResponse == null) return false;

      final studentId = studentResponse['id'];
      final existingEnrollment = await _client
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existingEnrollment != null) return false;

      await _client.from('course_enrollments').insert({
        'course_id': courseId,
        'student_id': studentId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'progress_percentage': 0.0,
        'total_time_spent': 0,
        'lessons_completed': 0,
        'is_active': true,
      });

      return true;
    } catch (e) {
      print('Error enrolling in course: $e');
      return false;
    }
  }

  // Check enrollment status
  static Future<bool> isUserEnrolled(String courseId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final studentResponse = await _client
          .from('students')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (studentResponse == null) return false;

      final enrollmentResponse = await _client
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('student_id', studentResponse['id'])
          .eq('is_active', true)
          .maybeSingle();

      return enrollmentResponse != null;
    } catch (e) {
      print('Error checking enrollment: $e');
      return false;
    }
  }
}
