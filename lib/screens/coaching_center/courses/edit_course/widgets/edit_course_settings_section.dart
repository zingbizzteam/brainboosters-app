import 'package:flutter/material.dart';

class EditCourseSettingsSection extends StatelessWidget {
  final bool isCertified;
  final bool isPublished;
  final Function(bool) onCertifiedChanged;
  final Function(bool) onPublishedChanged;
  final BoxConstraints constraints;

  const EditCourseSettingsSection({
    super.key,
    required this.isCertified,
    required this.isPublished,
    required this.onCertifiedChanged,
    required this.onPublishedChanged,
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
                  child: const Icon(Icons.settings_outlined, color: Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Course Settings',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
            
            // Settings Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Certificate Toggle
                  SwitchListTile(
                    title: const Text(
                      'Provide Certificate',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Students will receive a certificate upon completion'),
                    value: isCertified,
                    onChanged: onCertifiedChanged,
                    activeColor: const Color(0xFF00B894),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCertified 
                            ? const Color(0xFF00B894).withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.card_membership,
                        color: isCertified ? const Color(0xFF00B894) : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const Divider(height: 32),
                  
                  // Publish Toggle
                  SwitchListTile(
                    title: const Text(
                      'Publish Course',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isPublished 
                          ? 'Course is visible to students'
                          : 'Course is saved as draft',
                    ),
                    value: isPublished,
                    onChanged: onPublishedChanged,
                    activeColor: const Color(0xFF00B894),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPublished 
                            ? const Color(0xFF00B894).withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPublished ? Icons.visibility : Icons.visibility_off,
                        color: isPublished ? const Color(0xFF00B894) : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Course Features Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
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
                  _buildFeatureItem(
                    'Lifetime Access',
                    'Students get lifetime access to course content',
                    Icons.all_inclusive,
                  ),
                  _buildFeatureItem(
                    'Mobile Access',
                    'Course can be accessed on mobile devices',
                    Icons.smartphone,
                  ),
                  _buildFeatureItem(
                    'Q&A Support',
                    'Students can ask questions and get answers',
                    Icons.help_outline,
                  ),
                  if (isCertified)
                    _buildFeatureItem(
                      'Certificate',
                      'Certificate of completion provided',
                      Icons.card_membership,
                    ),
                ],
              ),
            ),
            
            // Publishing Guidelines
            if (isPublished) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
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

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.blue[600],
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
                const SizedBox(height: 2),
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
      padding: const EdgeInsets.only(bottom: 8),
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
