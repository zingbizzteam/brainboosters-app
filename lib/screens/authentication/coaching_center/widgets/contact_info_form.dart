// screens/authentication/coaching_center/widgets/contact_info_form.dart
import 'package:flutter/material.dart';

class ContactInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const ContactInfoForm({
    super.key,
    required this.formKey,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<ContactInfoForm> createState() => _ContactInfoFormState();
}

class _ContactInfoFormState extends State<ContactInfoForm> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.initialData['address'] ?? '');
    _cityController = TextEditingController(text: widget.initialData['city'] ?? '');
    _stateController = TextEditingController(text: widget.initialData['state'] ?? '');
    _pincodeController = TextEditingController(text: widget.initialData['pincode'] ?? '');
    _websiteController = TextEditingController(text: widget.initialData['website'] ?? '');

    // Add listeners
    _phoneController.addListener(_updateData);
    _addressController.addListener(_updateData);
    _cityController.addListener(_updateData);
    _stateController.addListener(_updateData);
    _pincodeController.addListener(_updateData);
    _websiteController.addListener(_updateData);

    // Initial data update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });
  }

  void _updateData() {
    widget.onDataChanged({
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'website': _websiteController.text,
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
              'Contact Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B894),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide your contact details and location',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Phone Number
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number *',
              hint: 'Enter contact phone number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Address
            _buildTextField(
              controller: _addressController,
              label: 'Address *',
              hint: 'Enter complete address',
              icon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // City and State Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City *',
                    hint: 'Enter city',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State *',
                    hint: 'Enter state',
                    icon: Icons.map,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pincode
            _buildTextField(
              controller: _pincodeController,
              label: 'Pincode *',
              hint: 'Enter pincode',
              icon: Icons.pin_drop,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Pincode is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Website
            _buildTextField(
              controller: _websiteController,
              label: 'Website URL',
              hint: 'Enter website URL (optional)',
              icon: Icons.web,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF00B894)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
