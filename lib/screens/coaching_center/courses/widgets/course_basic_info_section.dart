import 'package:flutter/material.dart';
import '../create_course_page.dart';

class CourseBasicInfoSection extends StatefulWidget {
  final CourseFormData formData;

  const CourseBasicInfoSection({super.key, required this.formData});

  @override
  State<CourseBasicInfoSection> createState() => _CourseBasicInfoSectionState();
}

class _CourseBasicInfoSectionState extends State<CourseBasicInfoSection> {
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
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Course Title
            TextFormField(
              controller: widget.formData.titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title *',
                hintText: 'Enter course title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Course title is required';
                }
                if (value.trim().length < 5) {
                  return 'Course title must be at least 5 characters';
                }
                return null;
              },
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            
            // Course Description
            TextFormField(
              controller: widget.formData.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Course Description *',
                hintText: 'Describe what students will learn in this course',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Course description is required';
                }
                if (value.trim().length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            
            // Duration
            TextFormField(
              controller: widget.formData.durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (Hours) *',
                hintText: 'Enter course duration in hours',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 16),
            
            // Language Selection
            DropdownButtonFormField<String>(
              value: widget.formData.selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
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
              onChanged: (value) {
                setState(() {
                  widget.formData.selectedLanguage = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a language';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
