import 'package:flutter/material.dart';
import '../create_course_page.dart';

class CourseSettingsSection extends StatefulWidget {
  final CourseFormData formData;

  const CourseSettingsSection({super.key, required this.formData});

  @override
  State<CourseSettingsSection> createState() => _CourseSettingsSectionState();
}

class _CourseSettingsSectionState extends State<CourseSettingsSection> {
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
              'Course Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Certificate Toggle
            SwitchListTile(
              title: const Text('Provide Certificate'),
              subtitle: const Text('Students will receive a certificate upon completion'),
              value: widget.formData.isCertified,
              onChanged: (value) {
                setState(() {
                  widget.formData.isCertified = value;
                });
              },
              activeColor: const Color(0xFF00B894),
              secondary: const Icon(Icons.card_membership),
            ),
            
            const Divider(),
            
            // Publish Toggle
            SwitchListTile(
              title: const Text('Publish Course'),
              subtitle: Text(
                widget.formData.isPublished 
                    ? 'Course will be visible to students immediately'
                    : 'Course will be saved as draft',
              ),
              value: widget.formData.isPublished,
              onChanged: (value) {
                setState(() {
                  widget.formData.isPublished = value;
                });
              },
              activeColor: const Color(0xFF00B894),
              secondary: Icon(
                widget.formData.isPublished ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Course Features Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Course Features',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('Lifetime Access', 'Students get lifetime access to course content'),
                  _buildFeatureItem('Mobile Access', 'Course can be accessed on mobile devices'),
                  _buildFeatureItem('Q&A Support', 'Students can ask questions and get answers'),
                  if (widget.formData.isCertified)
                    _buildFeatureItem('Certificate', 'Certificate of completion provided'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Publishing Guidelines
            if (widget.formData.isPublished) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Publishing Guidelines',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuidelineItem('Ensure all course content is complete and accurate'),
                    _buildGuidelineItem('Add proper course image and intro video'),
                    _buildGuidelineItem('Set appropriate pricing and course details'),
                    _buildGuidelineItem('Course will be reviewed before going live'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.orange[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
