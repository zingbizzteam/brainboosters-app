import 'package:brainboosters_app/screens/common/courses/assesment/assessment_repository.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/course_player_repository.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/widgets/lesson_assignments_widget.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/widgets/lesson_content_widget.dart';
import 'package:brainboosters_app/screens/common/courses/course_player/widgets/lesson_navigation_widget.dart';
import 'package:brainboosters_app/screens/common/widgets/common_video_player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoursePlayerPage extends StatefulWidget {
  final String courseId;
  final String? lessonId;
  final String? chapterId;

  const CoursePlayerPage({
    super.key,
    required this.courseId,
    this.lessonId,
    this.chapterId,
  });

  @override
  State<CoursePlayerPage> createState() => _CoursePlayerPageState();
}

class _CoursePlayerPageState extends State<CoursePlayerPage> {
  Map<String, dynamic>? _courseData;
  Map<String, dynamic>? _currentLesson;
  List<Map<String, dynamic>> _chapters = [];
  bool _isLoading = true;
  String? _error;
  bool _hasAccess = false;

  // Video player state
  String? _videoUrl;
  Duration _lastWatchPosition = Duration.zero;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final results = await Future.wait([
        CoursePlayerRepository.getCourseWithChapters(widget.courseId),
        CoursePlayerRepository.checkCourseAccess(widget.courseId),
      ]);

      // Check mounted after async operations
      if (!mounted) return;

      final courseData = results[0];
      final accessData = results[1] as Map<String, dynamic>;

      if (courseData == null) {
        if (mounted) {
          setState(() {
            _error = 'Course not found';
            _isLoading = false;
          });
        }
        return;
      }

      _chapters = (courseData['chapters'] as List?)
              ?.map((c) => Map<String, dynamic>.from(c))
              .toList() ??
          [];

      // Determine which lesson to show
      String? targetLessonId = widget.lessonId;
      if (targetLessonId == null && _chapters.isNotEmpty) {
        final firstChapter = _chapters.first;
        final lessons = firstChapter['lessons'] as List?;
        if (lessons != null && lessons.isNotEmpty) {
          targetLessonId = lessons.first['id'];
        }
      }

      Map<String, dynamic>? currentLesson;
      if (targetLessonId != null) {
        currentLesson = await CoursePlayerRepository.getLessonById(
          targetLessonId,
        );
      }

      // Final mounted check before setState
      if (!mounted) return;

      setState(() {
        _courseData = courseData;
        _currentLesson = currentLesson;
        _hasAccess = accessData['hasAccess'] ?? false;
        _isLoading = false;
      });

      if (currentLesson != null) {
        await _loadVideoForLesson(currentLesson);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load course: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVideoForLesson(Map<String, dynamic> lesson) async {
    if (!_hasAccess && !(lesson['is_free'] ?? false)) {
      if (mounted) {
        setState(() {
          _videoUrl = null;
          _isVideoLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isVideoLoading = true);
    }

    try {
      final results = await Future.wait([
        CoursePlayerRepository.getSecureVideoUrl(lesson['id']),
        CoursePlayerRepository.getLessonProgress(lesson['id']),
      ]);

      // Check mounted after async operations
      if (!mounted) return;

      final videoUrl = results[0] as String?;
      final progressData = results[1] as Map<String, dynamic>?;

      setState(() {
        _videoUrl = videoUrl;
        _lastWatchPosition = Duration(
          seconds: progressData?['last_position'] ?? 0,
        );
        _isVideoLoading = false;
      });

      if (videoUrl == null || videoUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lesson['lesson_type'] == 'video'
                    ? 'No video URL found for this lesson'
                    : 'This lesson is not a video lesson (type: ${lesson['lesson_type'] ?? 'unknown'})',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Video loading error: $e');
      if (mounted) {
        setState(() {
          _videoUrl = null;
          _isVideoLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onLessonChanged(String lessonId) async {
    try {
      // Check if widget is still mounted before starting async operations
      if (!mounted) return;
      
      final lesson = await CoursePlayerRepository.getLessonById(lessonId);
      
      // Check again after async operation
      if (!mounted) return;
      
      if (lesson != null) {
        setState(() => _currentLesson = lesson);
        await _loadVideoForLesson(lesson);
        
        // FIXED: Check mounted before using context
        if (mounted) {
          context.go('/course/${widget.courseId}/lesson/$lessonId');
        }
      }
    } catch (e) {
      // FIXED: Check mounted before showing SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lesson: $e')),
        );
      }
    }
  }

  Future<void> _onVideoProgress(Duration position, Duration duration) async {
    if (_currentLesson == null || !mounted) return;
    
    // Update progress every 10 seconds
    if (position.inSeconds % 10 == 0) {
      await CoursePlayerRepository.updateLessonProgress(
        _currentLesson!['id'],
        position.inSeconds,
        duration.inSeconds,
      );
    }
  }

  // FIXED: Proper assessment navigation
  Future<void> _onAssessmentSelected(String assessmentId) async {
    try {
      final assessment = await AssessmentRepository.getAssignmentById(assessmentId);
      if (assessment == null) return;

      if (!mounted) return;

      // Use proper route patterns that match your routing configuration
      final testType = assessment['test_type'] ?? 'assignment';
      String route;
      
      switch (testType) {
        case 'assignment':
          route = '/assignment/$assessmentId';
          break;
        case 'quiz':
        case 'exam':
        case 'practice':
          route = '/quiz/$assessmentId/attempt';
          break;
        default:
          route = '/assignment/$assessmentId';
      }

      // Add query parameters for context
      final params = <String>[];
      params.add('courseId=${widget.courseId}');
      if (_currentLesson?['id'] != null) {
        params.add('lessonId=${_currentLesson!['id']}');
      }
      
      if (params.isNotEmpty) {
        route += '?${params.join('&')}';
      }

      context.go(route);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load assessment: $e')),
        );
      }
    }
  }

  Future<void> _onVideoCompleted() async {
    if (_currentLesson == null || !mounted) return;
    
    await CoursePlayerRepository.markLessonCompleted(_currentLesson!['id']);
    
    // Auto-advance to next lesson
    final nextLesson = _findNextLesson();
    if (nextLesson != null && mounted) {
      await _onLessonChanged(nextLesson['id']);
    }
  }

  Map<String, dynamic>? _findNextLesson() {
    if (_currentLesson == null || _chapters.isEmpty) return null;

    String currentLessonId = _currentLesson!['id'];

    // Find current lesson position
    for (int chapterIndex = 0; chapterIndex < _chapters.length; chapterIndex++) {
      final chapter = _chapters[chapterIndex];
      final lessons = (chapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
        if (lessons[lessonIndex]['id'] == currentLessonId) {
          // Found current lesson, now find next
          if (lessonIndex + 1 < lessons.length) {
            // Next lesson in same chapter
            return lessons[lessonIndex + 1];
          } else if (chapterIndex + 1 < _chapters.length) {
            // First lesson of next chapter
            final nextChapter = _chapters[chapterIndex + 1];
            final nextLessons = (nextChapter['lessons'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            return nextLessons.isNotEmpty ? nextLessons.first : null;
          }
          return null; // No next lesson
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              ElevatedButton(
                onPressed: _loadCourseData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasAccess && !(_currentLesson?['is_free'] ?? false)) {
      return _buildAccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/course/${widget.courseId}');
            }
          },
        ),
        title: Text(_courseData?['title'] ?? 'Course'),
      ),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Video and content area
        Expanded(
          flex: 7,
          child: Column(
            children: [
              // Video player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CommonVideoPlayer(
                  videoUrl: _videoUrl,
                  startPosition: _lastWatchPosition,
                  onProgress: _onVideoProgress,
                  onCompleted: _onVideoCompleted,
                  isLoading: _isVideoLoading,
                ),
              ),
              // Lesson content
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: LessonContentWidget(
                    lesson: _currentLesson,
                    course: _courseData,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Navigation sidebar
        Container(
          width: 400,
          color: Colors.white,
          child: LessonNavigationWidget(
            chapters: _chapters,
            currentLessonId: _currentLesson?['id'],
            onLessonSelected: _onLessonChanged,
            onAssessmentSelected: _onAssessmentSelected,
            hasAccess: _hasAccess,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Video player (full width)
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CommonVideoPlayer(
            videoUrl: _videoUrl,
            startPosition: _lastWatchPosition,
            onProgress: _onVideoProgress,
            onCompleted: _onVideoCompleted,
            isLoading: _isVideoLoading,
          ),
        ),
        // Tabbed content area
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Content'),
                      Tab(text: 'Lessons'),
                      Tab(text: 'Assignments'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      LessonContentWidget(
                        lesson: _currentLesson,
                        course: _courseData,
                      ),
                      LessonNavigationWidget(
                        chapters: _chapters,
                        currentLessonId: _currentLesson?['id'],
                        onLessonSelected: _onLessonChanged,
                        onAssessmentSelected: _onAssessmentSelected,
                        hasAccess: _hasAccess,
                      ),
                      LessonAssignmentsWidget(
                        lessonId: _currentLesson?['id'],
                        courseId: widget.courseId, // FIXED: Pass courseId
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_courseData?['title'] ?? 'Course'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'Enrollment Required',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You need to enroll in this course to access this lesson.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/course/${widget.courseId}'),
                child: const Text('View Course Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
