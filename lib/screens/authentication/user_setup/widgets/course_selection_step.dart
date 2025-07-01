import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Course {
  final String name;
  final IconData icon;
  final Color color;

  Course(this.name, this.icon, this.color);
}

class CourseSelectionStep extends StatefulWidget {
  final List<String> selectedCourses;
  final void Function(String courseName) onCourseToggle;

  const CourseSelectionStep({
    super.key,
    required this.selectedCourses,
    required this.onCourseToggle,
  });

  @override
  State<CourseSelectionStep> createState() => _CourseSelectionStepState();
}

class _CourseSelectionStepState extends State<CourseSelectionStep> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Course> _courses = [];
  bool _isLoading = true;

  // Dynamic icon mapping based on keywords
  final Map<String, IconData> _keywordIcons = {
    'web': Icons.web,
    'mobile': Icons.phone_android,
    'app': Icons.phone_android,
    'data': Icons.analytics,
    'science': Icons.science,
    'machine': Icons.psychology,
    'learning': Icons.school,
    'ai': Icons.psychology,
    'devops': Icons.settings,
    'security': Icons.security,
    'cyber': Icons.security,
    'design': Icons.design_services,
    'ui': Icons.design_services,
    'ux': Icons.design_services,
    'marketing': Icons.campaign,
    'digital': Icons.campaign,
    'programming': Icons.code,
    'code': Icons.code,
    'python': Icons.code,
    'javascript': Icons.code,
    'java': Icons.code,
    'development': Icons.build,
    'full': Icons.layers,
    'stack': Icons.layers,
    'cloud': Icons.cloud,
    'database': Icons.storage,
    'sql': Icons.storage,
    'business': Icons.business,
    'management': Icons.business,
    'language': Icons.translate,
    'test': Icons.quiz,
    'exam': Icons.quiz,
    'preparation': Icons.quiz,
    'personal': Icons.self_improvement,
    'blockchain': Icons.link,
    'game': Icons.games,
    'network': Icons.network_check,
    'algorithm': Icons.account_tree,
    'structure': Icons.account_tree,
  };

  final List<Color> _colors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFF44336), // Red
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF009688), // Teal
    const Color(0xFF795548), // Brown
    const Color(0xFFE91E63), // Pink
    const Color(0xFFFFC107), // Amber
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFCDDC39), // Lime
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final response = await Supabase.instance.client
          .from('app_config')
          .select('config_value')
          .eq('config_key', 'learning_goals')
          .eq('is_active', true)
          .single();

      final courseNames = List<String>.from(response['config_value']);

      setState(() {
        _courses = courseNames.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          return Course(
            name,
            _getIconForCourse(name),
            _colors[index % _colors.length],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
      // Fallback to default courses
      setState(() {
        _courses = [
          Course('Web Development', Icons.web, const Color(0xFFFF9800)),
          Course(
            'Mobile Development',
            Icons.phone_android,
            const Color(0xFF009688),
          ),
          Course('Data Science', Icons.analytics, const Color(0xFF2196F3)),
          Course('Machine Learning', Icons.psychology, const Color(0xFF3F51B5)),
        ];
        _isLoading = false;
      });
    }
  }

  // Dynamic icon selection based on course name keywords
  IconData _getIconForCourse(String courseName) {
    final lowerName = courseName.toLowerCase();

    // Check for keyword matches
    for (final entry in _keywordIcons.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default icon if no keyword matches
    return Icons.school;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> get _filteredCourses {
    if (_searchQuery.isEmpty) return _courses;
    return _courses
        .where(
          (course) =>
              course.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed header section
        const Text(
          "Choose your learning goals",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Search Field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search learning goals...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 16),

        const Text(
          "Select multiple goals that interest you",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),

        // Course Grid - Use Expanded to fill available space
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCourses.isEmpty
              ? const Center(
                  child: Text(
                    'No learning goals found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _filteredCourses.map((course) {
                    final isSelected = widget.selectedCourses.contains(
                      course.name,
                    );
                    return SizedBox(
                      width:
                          (MediaQuery.of(context).size.width - 72) /
                          2, // Half width minus padding
                      height: 120, // Fixed height for each card
                      child: GestureDetector(
                        onTap: () => widget.onCourseToggle(course.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? course.color
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? course.color.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.05),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: course.color.withValues(
                                    alpha: isSelected ? 0.2 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  course.icon,
                                  color: course.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  course.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? course.color
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(height: 4),

                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: course.color,
                                  size: 16,
                                )
                              else
                                const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
