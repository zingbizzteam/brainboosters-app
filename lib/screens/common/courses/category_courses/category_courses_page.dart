// screens/common/courses/category_courses_page.dart

import 'package:brainboosters_app/screens/common/courses/widgets/all_courses_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryCoursesPage extends StatefulWidget {
  final String categoryName;

  const CategoryCoursesPage({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryCoursesPage> createState() => _CategoryCoursesPageState();
}

class _CategoryCoursesPageState extends State<CategoryCoursesPage> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;
  final int pageSize = 12;
  int currentOffset = 0;
  final ScrollController _scrollController = ScrollController();
  String? categoryId; // ✅ Store category ID

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ NEW: First get category ID from category name
  Future<void> _initializePage() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Get category ID by name or slug
      final categoryResponse = await Supabase.instance.client
          .from('course_categories')
          .select('id')
          .or('name.ilike.${widget.categoryName},slug.ilike.${widget.categoryName}')
          .maybeSingle();

      if (categoryResponse == null) {
        if (mounted) {
          setState(() {
            error = 'Category "${widget.categoryName}" not found';
            isLoading = false;
          });
        }
        return;
      }

      categoryId = categoryResponse['id'];
      await _loadCourses();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to initialize: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCourses({bool isRefresh = false}) async {
    if (categoryId == null) return;

    try {
      if (isRefresh) {
        setState(() {
          isLoading = true;
          error = null;
          currentOffset = 0;
          courses.clear();
        });
      } else if (!isLoading) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      // ✅ FIXED: Use category_id and join with course_categories
      final response = await Supabase.instance.client
          .from('courses')
          .select('''
            id,
            title,
            thumbnail_url,
            category_id,
            course_categories!inner(name, slug),
            level,
            price,
            original_price,
            is_published,
            rating,
            total_lessons,
            duration_hours,
            enrollment_count,
            total_reviews,
            coaching_centers(center_name)
          ''')
          .eq('is_published', true)
          .eq('category_id', categoryId!) // ✅ Filter by category_id
          .order('enrollment_count', ascending: false)
          .range(currentOffset, currentOffset + pageSize - 1);

      if (mounted) {
        setState(() {
          if (isRefresh) {
            courses = List<Map<String, dynamic>>.from(response);
          } else {
            courses.addAll(List<Map<String, dynamic>>.from(response));
          }

          hasMore = response.length == pageSize;
          currentOffset += response.length;
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load courses: $e';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreCourses() async {
    if (isLoadingMore || !hasMore || categoryId == null) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      // ✅ FIXED: Use category_id and join with course_categories
      final response = await Supabase.instance.client
          .from('courses')
          .select('''
            id,
            title,
            thumbnail_url,
            category_id,
            course_categories!inner(name, slug),
            level,
            price,
            original_price,
            is_published,
            rating,
            total_lessons,
            duration_hours,
            enrollment_count,
            total_reviews,
            coaching_centers(center_name)
          ''')
          .eq('is_published', true)
          .eq('category_id', categoryId!)
          .order('enrollment_count', ascending: false)
          .range(currentOffset, currentOffset + pageSize - 1);

      if (mounted) {
        setState(() {
          courses.addAll(List<Map<String, dynamic>>.from(response));
          hasMore = response.length == pageSize;
          currentOffset += response.length;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more courses: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadMoreCourses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.categoryName} Courses'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadCourses(isRefresh: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: AllCoursesGrid(
            courses: courses,
            loading: isLoading,
            loadingMore: isLoadingMore,
            hasMore: hasMore,
            errorMessage: error,
            onRetry: () => _initializePage(),
          ),
        ),
      ),
    );
  }
}
