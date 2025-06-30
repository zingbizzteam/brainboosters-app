import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditCourseBasicInfo extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController durationController;
  final String selectedLanguage;
  final Function(String) onLanguageChanged;
  final BoxConstraints constraints;

  const EditCourseBasicInfo({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.durationController,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.constraints,
  });

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
                  child: const Icon(Icons.info_outline, color: Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
            
            _buildTextField(
              controller: titleController,
              label: 'Course Title',
              hint: 'Enter course title (5-100 characters)',
              isRequired: true,
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Course title is required';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                if (value.trim().length > 100) {
                  return 'Title cannot exceed 100 characters';
                }
                return null;
              },
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
            
            _buildTextField(
              controller: descriptionController,
              label: 'Course Description',
              hint: 'Describe what students will learn (20-500 words)',
              maxLines: 6,
              isRequired: true,
              maxLength: 3000, // Approximately 500 words
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Course description is required';
                }
                final wordCount = _getWordCount(value.trim());
                if (wordCount < 20) {
                  return 'Description must be at least 20 words';
                }
                if (wordCount > 500) {
                  return 'Description cannot exceed 500 words';
                }
                return null;
              },
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
            
            _buildTextField(
              controller: durationController,
              label: 'Duration (Hours)',
              hint: '1-1000 hours',
              keyboardType: TextInputType.number,
              isRequired: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Duration is required';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration <= 0) {
                  return 'Enter a valid duration';
                }
                if (duration > 1000) {
                  return 'Duration cannot exceed 1000 hours';
                }
                return null;
              },
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
            
            _buildLanguageDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: constraints.maxWidth > 600 ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            children: isRequired
                ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: (value) {
            // Real-time validation for description word count
            if (label.contains('Description') && value.isNotEmpty) {
              final wordCount = _getWordCount(value.trim());
              // You could add real-time feedback here if needed
            }
          },
          decoration: InputDecoration(
            hintText: hint,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
            // Add helper text for description
            helperText: label.contains('Description') 
                ? 'Current words: ${_getWordCount(controller.text)} / 500'
                : null,
            helperStyle: TextStyle(
              color: _getWordCount(controller.text) > 500 
                  ? Colors.red 
                  : Colors.grey[600],
              fontSize: 12,
            ),
            counterText: maxLength != null ? null : '', // Hide default counter for custom ones
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language *',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedLanguage,
          onChanged: (value) => onLanguageChanged(value!),
          isExpanded: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a language';
            }
            return null;
          },
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'english', child: Text('English')),
            DropdownMenuItem(value: 'hindi', child: Text('Hindi')),
            DropdownMenuItem(value: 'tamil', child: Text('Tamil')),
            DropdownMenuItem(value: 'telugu', child: Text('Telugu')),
            DropdownMenuItem(value: 'kannada', child: Text('Kannada')),
            DropdownMenuItem(value: 'malayalam', child: Text('Malayalam')),
            DropdownMenuItem(value: 'bengali', child: Text('Bengali')),
            DropdownMenuItem(value: 'marathi', child: Text('Marathi')),
            DropdownMenuItem(value: 'gujarati', child: Text('Gujarati')),
            DropdownMenuItem(value: 'punjabi', child: Text('Punjabi')),
          ],
        ),
      ],
    );
  }

  // Helper method to count words in a string
  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
