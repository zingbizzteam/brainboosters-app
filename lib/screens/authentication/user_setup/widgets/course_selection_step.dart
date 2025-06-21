import 'package:flutter/material.dart';

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

  final List<Course> _courses = [
    Course('Data Structures & Algorithms', Icons.account_tree, Colors.blue),
    Course('Python Programming', Icons.code, Colors.green),
    Course('Web Development', Icons.web, Colors.orange),
    Course('Full Stack Development', Icons.layers, Colors.purple),
    Course('Cloud Computing', Icons.cloud, Colors.cyan),
    Course('Cybersecurity', Icons.security, Colors.red),
    Course('Machine Learning', Icons.psychology, Colors.indigo),
    Course('Mobile Development', Icons.phone_android, Colors.teal),
    Course('DevOps', Icons.settings, Colors.brown),
    Course('Database Management', Icons.storage, Colors.pink),
  ];

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
    final filteredCourses = _filteredCourses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Choose your goal",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              "Computer Science",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (filteredCourses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No courses found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  final isSelected = widget.selectedCourses.contains(
                    course.name,
                  );
                  return GestureDetector(
                    onTap: () => widget.onCourseToggle(course.name),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: course.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              course.icon,
                              color: course.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
