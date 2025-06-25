// screens/authentication/coaching_center/widgets/facility_info_form.dart
import 'package:flutter/material.dart';

class FacilityInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FacilityInfoForm({
    super.key,
    required this.formKey,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<FacilityInfoForm> createState() => _FacilityInfoFormState();
}

class _FacilityInfoFormState extends State<FacilityInfoForm> {
  bool _hasOnlineClasses = false;
  bool _hasOfflineClasses = true;
  bool _hasHybridClasses = false;
  bool _hasLibrary = false;
  bool _hasLabFacility = false;
  bool _hasHostelFacility = false;
  bool _hasCafeteria = false;
  bool _hasTransportFacility = false;

  late List<String> _selectedFacilities;

  final List<String> _availableFacilities = [
    'Air Conditioning',
    'WiFi',
    'Parking',
    'Security',
    'Elevator',
    'Wheelchair Access',
    'Audio Visual Equipment',
    'Whiteboard/Smartboard',
    'Study Hall',
    'Computer Lab',
    'Science Lab',
    'Sports Facility',
    'Medical Facility',
    'Counseling Services',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _hasOnlineClasses = widget.initialData['hasOnlineClasses'] ?? false;
    _hasOfflineClasses = widget.initialData['hasOfflineClasses'] ?? true;
    _hasHybridClasses = widget.initialData['hasHybridClasses'] ?? false;
    _hasLibrary = widget.initialData['hasLibrary'] ?? false;
    _hasLabFacility = widget.initialData['hasLabFacility'] ?? false;
    _hasHostelFacility = widget.initialData['hasHostelFacility'] ?? false;
    _hasCafeteria = widget.initialData['hasCafeteria'] ?? false;
    _hasTransportFacility = widget.initialData['hasTransportFacility'] ?? false;
    _selectedFacilities = List<String>.from(widget.initialData['facilities'] ?? []);

    // Initial data update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });
  }

  void _updateData() {
    widget.onDataChanged({
      'hasOnlineClasses': _hasOnlineClasses,
      'hasOfflineClasses': _hasOfflineClasses,
      'hasHybridClasses': _hasHybridClasses,
      'hasLibrary': _hasLibrary,
      'hasLabFacility': _hasLabFacility,
      'hasHostelFacility': _hasHostelFacility,
      'hasCafeteria': _hasCafeteria,
      'hasTransportFacility': _hasTransportFacility,
      'facilities': _selectedFacilities,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Facilities & Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B894),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about your facilities and teaching modes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Teaching Modes
            _buildSectionTitle('Teaching Modes'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Online Classes',
              'Offer classes through video conferencing',
              Icons.computer,
              _hasOnlineClasses,
              (value) {
                setState(() {
                  _hasOnlineClasses = value;
                });
                _updateData();
              },
            ),
            _buildSwitchTile(
              'Offline Classes',
              'Traditional classroom teaching',
              Icons.school,
              _hasOfflineClasses,
              (value) {
                setState(() {
                  _hasOfflineClasses = value;
                });
                _updateData();
              },
            ),
            _buildSwitchTile(
              'Hybrid Classes',
              'Combination of online and offline',
              Icons.merge_type,
              _hasHybridClasses,
              (value) {
                setState(() {
                  _hasHybridClasses = value;
                });
                _updateData();
              },
            ),

            const SizedBox(height: 32),

            // Core Facilities
            _buildSectionTitle('Core Facilities'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Library',
              'Reading room and book collection',
              Icons.library_books,
              _hasLibrary,
              (value) {
                setState(() {
                  _hasLibrary = value;
                });
                _updateData();
              },
            ),
            _buildSwitchTile(
              'Laboratory Facility',
              'Science/Computer lab for practical learning',
              Icons.science,
              _hasLabFacility,
              (value) {
                setState(() {
                  _hasLabFacility = value;
                });
                _updateData();
              },
            ),
            _buildSwitchTile(
              'Hostel Facility',
              'Accommodation for outstation students',
              Icons.hotel,
              _hasHostelFacility,
              (value) {
                setState(() {
                  _hasHostelFacility = value;
                });
                _updateData();
              },
            ),
            _buildSwitchTile(
              'Cafeteria',
              'Food and refreshment facility',
              Icons.restaurant,
              _hasCafeteria,
              (value) {
                setState(() {
                  _hasCafeteria = value;
                });
                _updateData();
              },
            ),
            _buildSwitchTile(
              'Transport Facility',
              'Bus service for students',
              Icons.directions_bus,
              _hasTransportFacility,
              (value) {
                setState(() {
                  _hasTransportFacility = value;
                });
                _updateData();
              },
            ),

            const SizedBox(height: 32),

            // Additional Facilities
            _buildSectionTitle('Additional Facilities'),
            const SizedBox(height: 16),
            _buildFacilityChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00B894), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00B894),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableFacilities.map((facility) {
        final isSelected = _selectedFacilities.contains(facility);
        return FilterChip(
          label: Text(facility),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFacilities.add(facility);
              } else {
                _selectedFacilities.remove(facility);
              }
            });
            _updateData();
          },
          selectedColor: const Color(0xFF00B894).withValues(alpha: 0.2),
          checkmarkColor: const Color(0xFF00B894),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF00B894) : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
