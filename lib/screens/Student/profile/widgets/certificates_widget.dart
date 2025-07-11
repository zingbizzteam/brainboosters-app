import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../profile_repository.dart';

class CertificatesWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const CertificatesWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<CertificatesWidget> createState() => _CertificatesWidgetState();
}

class _CertificatesWidgetState extends State<CertificatesWidget> {
  List<Map<String, dynamic>> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    
    try {
      final certificates = await ProfileRepository.getCertificates();
      setState(() {
        _certificates = certificates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load certificates: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_certificates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No certificates earned yet'),
            SizedBox(height: 8),
            Text(
              'Complete courses to earn certificates!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with download all button
        Row(
          children: [
            Text(
              '${_certificates.length} Certificate${_certificates.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _downloadAllCertificates,
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download All'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Certificates Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: _certificates.length,
            itemBuilder: (context, index) {
              return _buildCertificateCard(_certificates[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> certificate) {
    final course = certificate['courses'] as Map<String, dynamic>;
    final completedAt = DateTime.parse(certificate['completed_at']);
    final teacherProfile = certificate['courses']['teachers']['user_profiles'] as Map<String, dynamic>?;
    final teacherName = teacherProfile != null 
        ? '${teacherProfile['first_name']} ${teacherProfile['last_name']}'
        : 'Unknown Teacher';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Icon and Title
            Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Certificate of Completion',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Course Title
            Text(
              course['title'] ?? 'Untitled Course',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Teacher Name
            Text(
              'By $teacherName',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),

            // Completion Date
            Text(
              'Completed: ${DateFormat('MMM dd, yyyy').format(completedAt)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadCertificate(certificate),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadCertificate(Map<String, dynamic> certificate) {
    final certificateUrl = certificate['completion_certificate_url'];
    if (certificateUrl != null) {
      // Implement certificate download
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate download started!'),
        ),
      );
    }
  }

  void _downloadAllCertificates() {
    // Implement bulk certificate download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading all certificates...'),
      ),
    );
  }
}
