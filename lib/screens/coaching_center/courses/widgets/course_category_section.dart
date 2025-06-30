import 'package:flutter/material.dart';
import '../create_course_page.dart';

class CourseCategorySection extends StatefulWidget {
  final CourseFormData formData;

  const CourseCategorySection({super.key, required this.formData});

  @override
  State<CourseCategorySection> createState() => _CourseCategorySectionState();
}

class _CourseCategorySectionState extends State<CourseCategorySection> {
  final Map<String, List<String>> categorySubcategories = {
    'programming': ['web_development', 'mobile_development', 'data_science', 'ai_ml', 'game_development'],
    'design': ['ui_ux', 'graphic_design', 'web_design', 'animation', 'photography'],
    'business': ['marketing', 'finance', 'entrepreneurship', 'management', 'sales'],
    'academics': ['mathematics', 'science', 'english', 'history', 'geography'],
    'test_prep': ['jee', 'neet', 'upsc', 'gate', 'cat', 'gmat', 'ielts', 'toefl'],
    'language': ['english', 'hindi', 'spanish', 'french', 'german', 'japanese'],
    'music': ['guitar', 'piano', 'vocals', 'drums', 'violin'],
    'fitness': ['yoga', 'gym', 'dance', 'martial_arts', 'sports'],
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category & Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Category Selection
            DropdownButtonFormField<String>(
              value: widget.formData.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: categorySubcategories.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_formatCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.formData.selectedCategory = value!;
                  // Reset subcategory when category changes
                  widget.formData.selectedSubcategory = 
                      categorySubcategories[value]!.first;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Subcategory Selection
            DropdownButtonFormField<String>(
              value: widget.formData.selectedSubcategory,
              decoration: const InputDecoration(
                labelText: 'Subcategory *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
              items: categorySubcategories[widget.formData.selectedCategory]!
                  .map((subcategory) {
                return DropdownMenuItem(
                  value: subcategory,
                  child: Text(_formatCategoryName(subcategory)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.formData.selectedSubcategory = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a subcategory';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Level Selection
            DropdownButtonFormField<String>(
              value: widget.formData.selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Level *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_up),
              ),
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                DropdownMenuItem(value: 'expert', child: Text('Expert')),
              ],
              onChanged: (value) {
                setState(() {
                  widget.formData.selectedLevel = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Difficulty Selection
            DropdownButtonFormField<String>(
              value: widget.formData.selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                DropdownMenuItem(value: 'Expert', child: Text('Expert')),
              ],
              onChanged: (value) {
                setState(() {
                  widget.formData.selectedDifficulty = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select difficulty';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
