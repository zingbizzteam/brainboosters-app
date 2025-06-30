import 'package:flutter/material.dart';

class EditCourseCategorySection extends StatelessWidget {
  final String selectedCategory;
  final String selectedSubcategory;
  final String selectedLevel;
  final String selectedDifficulty;
  final Function(String, String) onCategoryChanged;
  final Function(String) onLevelChanged;
  final Function(String) onDifficultyChanged;
  final BoxConstraints constraints;

  const EditCourseCategorySection({
    super.key,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.selectedLevel,
    required this.selectedDifficulty,
    required this.onCategoryChanged,
    required this.onLevelChanged,
    required this.onDifficultyChanged,
    required this.constraints,
  });

  final Map<String, List<String>> _subcategories = const {
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
                  child: const Icon(Icons.category_outlined, color: Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Category & Classification',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
            
            if (constraints.maxWidth > 600)
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildSubcategoryDropdown()),
                ],
              )
            else ...[
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildSubcategoryDropdown(),
            ],
            
            SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
            
            if (constraints.maxWidth > 600)
              Row(
                children: [
                  Expanded(child: _buildLevelDropdown()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDifficultyDropdown()),
                ],
              )
            else ...[
              _buildLevelDropdown(),
              const SizedBox(height: 16),
              _buildDifficultyDropdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          onChanged: (value) {
            if (value != null) {
              final firstSubcategory = _subcategories[value]!.first;
              onCategoryChanged(value, firstSubcategory);
            }
          },
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
          items: _subcategories.keys.map((category) => DropdownMenuItem(
            value: category,
            child: Text(
              _formatCategoryName(category),
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSubcategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subcategory *',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedSubcategory,
          onChanged: (value) {
            if (value != null) {
              onCategoryChanged(selectedCategory, value);
            }
          },
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
          items: _subcategories[selectedCategory]!.map((subcategory) => DropdownMenuItem(
            value: subcategory,
            child: Text(
              _formatCategoryName(subcategory),
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level *',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedLevel,
          onChanged: (value) => onLevelChanged(value!),
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
          items: const [
            DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
            DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
            DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
            DropdownMenuItem(value: 'expert', child: Text('Expert')),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty *',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDifficulty,
          onChanged: (value) => onDifficultyChanged(value!),
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
          items: const [
            DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
            DropdownMenuItem(value: 'Easy', child: Text('Easy')),
            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
            DropdownMenuItem(value: 'Hard', child: Text('Hard')),
            DropdownMenuItem(value: 'Expert', child: Text('Expert')),
          ],
        ),
      ],
    );
  }

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
