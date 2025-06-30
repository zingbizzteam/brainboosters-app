import 'package:flutter/material.dart';
import '../create_course_page.dart';

class CourseContentSection extends StatefulWidget {
  final CourseFormData formData;

  const CourseContentSection({super.key, required this.formData});

  @override
  State<CourseContentSection> createState() => _CourseContentSectionState();
}

class _CourseContentSectionState extends State<CourseContentSection> {
  final TextEditingController _learningOutcomeController = TextEditingController();
  final TextEditingController _prerequisiteController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _learningOutcomeController.dispose();
    _prerequisiteController.dispose();
    _requirementController.dispose();
    _tagController.dispose();
    super.dispose();
  }

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
              'Course Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Learning Outcomes
            _buildListSection(
              title: 'What will students learn?',
              subtitle: 'Add learning outcomes for this course',
              controller: _learningOutcomeController,
              items: widget.formData.learningOutcomes,
              onAdd: _addLearningOutcome,
              onRemove: (index) => _removeLearningOutcome(index),
              icon: Icons.school,
              hintText: 'e.g., Build responsive websites using HTML, CSS, and JavaScript',
            ),
            
            const SizedBox(height: 24),
            
            // Prerequisites
            _buildListSection(
              title: 'Prerequisites',
              subtitle: 'What should students know before taking this course?',
              controller: _prerequisiteController,
              items: widget.formData.prerequisites,
              onAdd: _addPrerequisite,
              onRemove: (index) => _removePrerequisite(index),
              icon: Icons.checklist,
              hintText: 'e.g., Basic understanding of programming concepts',
            ),
            
            const SizedBox(height: 24),
            
            // Requirements
            _buildListSection(
              title: 'Requirements',
              subtitle: 'What do students need to complete this course?',
              controller: _requirementController,
              items: widget.formData.requirements,
              onAdd: _addRequirement,
              onRemove: (index) => _removeRequirement(index),
              icon: Icons.laptop,
              hintText: 'e.g., Computer with internet connection',
            ),
            
            const SizedBox(height: 24),
            
            // Tags
            _buildListSection(
              title: 'Tags',
              subtitle: 'Add tags to help students find your course',
              controller: _tagController,
              items: widget.formData.tags,
              onAdd: _addTag,
              onRemove: (index) => _removeTag(index),
              icon: Icons.tag,
              hintText: 'e.g., web development, javascript, react',
              isTag: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required IconData icon,
    required String hintText,
    bool isTag = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        
        // Input field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: isTag ? 1 : 2,
                onFieldSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Items list
        if (items.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isTag ? _buildTagsWrap(items, onRemove) : _buildItemsList(items, onRemove),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No items added yet',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemsList(List<String> items, Function(int) onRemove) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B894),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () => onRemove(index),
                icon: const Icon(Icons.close, size: 18),
                color: Colors.red,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsWrap(List<String> items, Function(int) onRemove) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Chip(
          label: Text(item),
          onDeleted: () => onRemove(index),
          deleteIcon: const Icon(Icons.close, size: 16),
          backgroundColor: const Color(0xFF00B894).withOpacity(0.1),
          labelStyle: const TextStyle(color: Color(0xFF00B894)),
          deleteIconColor: Colors.red,
        );
      }).toList(),
    );
  }

  void _addLearningOutcome() {
    if (_learningOutcomeController.text.trim().isNotEmpty) {
      setState(() {
        widget.formData.learningOutcomes.add(_learningOutcomeController.text.trim());
        _learningOutcomeController.clear();
      });
    }
  }

  void _removeLearningOutcome(int index) {
    setState(() {
      widget.formData.learningOutcomes.removeAt(index);
    });
  }

  void _addPrerequisite() {
    if (_prerequisiteController.text.trim().isNotEmpty) {
      setState(() {
        widget.formData.prerequisites.add(_prerequisiteController.text.trim());
        _prerequisiteController.clear();
      });
    }
  }

  void _removePrerequisite(int index) {
    setState(() {
      widget.formData.prerequisites.removeAt(index);
    });
  }

  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() {
        widget.formData.requirements.add(_requirementController.text.trim());
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      widget.formData.requirements.removeAt(index);
    });
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      final tag = _tagController.text.trim().toLowerCase();
      if (!widget.formData.tags.contains(tag)) {
        setState(() {
          widget.formData.tags.add(tag);
          _tagController.clear();
        });
      }
    }
  }

  void _removeTag(int index) {
    setState(() {
      widget.formData.tags.removeAt(index);
    });
  }
}
