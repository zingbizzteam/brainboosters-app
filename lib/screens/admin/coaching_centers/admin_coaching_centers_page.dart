// screens/admin/coaching_centers/admin_coaching_centers_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCoachingCentersPage extends StatefulWidget {
  const AdminCoachingCentersPage({super.key});

  @override
  State<AdminCoachingCentersPage> createState() =>
      _AdminCoachingCentersPageState();
}

class _AdminCoachingCentersPageState extends State<AdminCoachingCentersPage> {
  List<Map<String, dynamic>> _pendingRegistrations = [];
  List<Map<String, dynamic>> _approvedCenters = [];
  List<Map<String, dynamic>> _emailPendingRegistrations =
      []; // Add this missing variable
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Load pending registrations (email verified, waiting for admin approval)
      final pendingResponse = await Supabase.instance.client
          .from('coaching_centers')
          .select()
          .eq('verification_status', 'pending')
          .order('created_at', ascending: false);

      // Load email pending registrations (for information only)
      final emailPendingResponse = await Supabase.instance.client
          .from('coaching_centers')
          .select()
          .eq('verification_status', 'email_pending')
          .order('created_at', ascending: false);

      // Load approved centers
      final approvedResponse = await Supabase.instance.client
          .from('coaching_centers')
          .select()
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _pendingRegistrations = List<Map<String, dynamic>>.from(
            pendingResponse,
          );
          _emailPendingRegistrations = List<Map<String, dynamic>>.from(
            emailPendingResponse,
          );
          _approvedCenters = List<Map<String, dynamic>>.from(approvedResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Confirm user email using admin API
  Future<void> _confirmUserEmail(String userId) async {
    try {
      await Supabase.instance.client.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(emailConfirm: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email confirmed successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _approveRegistration(Map<String, dynamic> center) async {
    try {
      // Update user profile to activate account
      await Supabase.instance.client
          .from('user_profiles')
          .update({
            'is_active': true,
            'is_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', center['id']);

      // Update coaching center verification status
      await Supabase.instance.client
          .from('coaching_centers')
          .update({
            'is_verified': true,
            'verification_status': 'approved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', center['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coaching center approved! They can now login.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add the missing _rejectRegistration method
  Future<void> _rejectRegistration(Map<String, dynamic> center) async {
    // Show confirmation dialog first
    final confirmed = await _showConfirmationDialog(
      'Reject Registration',
      'Are you sure you want to reject ${center['center_name']}? This action cannot be undone.',
      'Reject',
      Colors.red,
    );

    if (!confirmed) return;

    try {
      // Update coaching center to rejected status
      await Supabase.instance.client
          .from('coaching_centers')
          .update({
            'verification_status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', center['id']);

      // Deactivate the user account
      await Supabase.instance.client
          .from('user_profiles')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', center['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              title,
              style: const TextStyle(color: Color(0xFF222B45)),
            ),
            content: Text(
              content,
              style: const TextStyle(color: Color(0xFF6E7A8A)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF6E7A8A)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: actionColor),
                child: Text(
                  actionText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Column(
        children: [
          // Header with tabs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE9EDF2).withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Coaching Centers',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222B45),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_pendingRegistrations.length} Pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh, color: Color(0xFF4AA0E6)),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0
                                ? const Color(0xFF4AA0E6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pending (${_pendingRegistrations.length})',
                            style: TextStyle(
                              color: _selectedTabIndex == 0
                                  ? Colors.white
                                  : const Color(0xFF6E7A8A),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1
                                ? const Color(0xFF4AA0E6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Approved (${_approvedCenters.length})',
                            style: TextStyle(
                              color: _selectedTabIndex == 1
                                  ? Colors.white
                                  : const Color(0xFF6E7A8A),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4AA0E6)),
                  )
                : _selectedTabIndex == 0
                ? _buildPendingTab()
                : _buildApprovedTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingRegistrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No pending registrations',
              style: TextStyle(fontSize: 16, color: Color(0xFF6E7A8A)),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _pendingRegistrations[index];
          return _buildPendingRegistrationCard(registration);
        },
      ),
    );
  }

  Widget _buildPendingRegistrationCard(Map<String, dynamic> registration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE9EDF2).withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  registration['center_name'] ?? 'Unknown Center',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222B45),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Contact Person',
            registration['contact_person'] ?? 'N/A',
          ),
          _buildInfoRow('Email', registration['contact_email'] ?? 'N/A'),
          _buildInfoRow('Phone', registration['contact_phone'] ?? 'N/A'),
          _buildInfoRow(
            'Location',
            '${registration['city'] ?? 'N/A'}, ${registration['state'] ?? 'N/A'}',
          ),
          _buildInfoRow('Address', registration['address'] ?? 'N/A'),
          _buildInfoRow('Submitted', _formatDate(registration['created_at'])),

          const SizedBox(height: 16),

          // Action buttons - Remove the email confirmation button since users verify themselves
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveRegistration(registration),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49D49D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectRegistration(registration),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // View details button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _viewCenterDetails(registration),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Full Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4AA0E6),
                side: const BorderSide(color: Color(0xFF4AA0E6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedTab() {
    if (_approvedCenters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No approved centers',
              style: TextStyle(fontSize: 16, color: Color(0xFF6E7A8A)),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _approvedCenters.length,
        itemBuilder: (context, index) {
          final center = _approvedCenters[index];
          return _buildApprovedCenterCard(center);
        },
      ),
    );
  }

  Widget _buildApprovedCenterCard(Map<String, dynamic> center) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE9EDF2).withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  center['center_name'] ?? 'Unknown Center',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222B45),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF49D49D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'APPROVED',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Contact Person', center['contact_person'] ?? 'N/A'),
          _buildInfoRow('Email', center['contact_email'] ?? 'N/A'),
          _buildInfoRow('Phone', center['contact_phone'] ?? 'N/A'),
          _buildInfoRow(
            'Location',
            '${center['city'] ?? 'N/A'}, ${center['state'] ?? 'N/A'}',
          ),
          _buildInfoRow('Center ID', center['center_id'] ?? 'N/A'),
          _buildInfoRow('Approved', _formatDate(center['created_at'])),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewCenterDetails(center),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4AA0E6),
                    side: const BorderSide(color: Color(0xFF4AA0E6)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _suspendCenter(center),
                  icon: const Icon(Icons.block),
                  label: const Text('Suspend'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E7A8A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF222B45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _viewCenterDetails(Map<String, dynamic> center) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          center['center_name'] ?? 'Unknown Center',
          style: const TextStyle(color: Color(0xFF222B45)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Center ID', center['center_id']),
              _buildDetailRow('Contact Person', center['contact_person']),
              _buildDetailRow('Designation', center['contact_designation']),
              _buildDetailRow('Email', center['contact_email']),
              _buildDetailRow('Phone', center['contact_phone']),
              _buildDetailRow('Address', center['address']),
              _buildDetailRow('City', center['city']),
              _buildDetailRow('State', center['state']),
              _buildDetailRow('Pincode', center['pincode']),
              _buildDetailRow('Website', center['website_url']),
              _buildDetailRow(
                'Establishment Year',
                center['establishment_year']?.toString(),
              ),
              _buildDetailRow('Category', center['category']),
              _buildDetailRow('Status', center['verification_status']),
              if (center['description'] != null &&
                  center['description'].toString().isNotEmpty)
                _buildDetailRow('Description', center['description']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4AA0E6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF6E7A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF222B45)),
            ),
          ),
        ],
      ),
    );
  }

  void _suspendCenter(Map<String, dynamic> center) async {
    final confirmed = await _showConfirmationDialog(
      'Suspend Center',
      'Are you sure you want to suspend ${center['center_name']}? They will not be able to login until reactivated.',
      'Suspend',
      Colors.orange,
    );

    if (!confirmed) return;

    try {
      // Update coaching center status
      await Supabase.instance.client
          .from('coaching_centers')
          .update({
            'verification_status': 'suspended',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', center['id']);

      // Deactivate user account
      await Supabase.instance.client
          .from('user_profiles')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', center['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${center['center_name']} suspended successfully'),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error suspending center: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
