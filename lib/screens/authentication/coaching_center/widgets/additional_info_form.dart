// screens/authentication/coaching_center/widgets/additional_info_form.dart
import 'package:flutter/material.dart';

class AdditionalInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AdditionalInfoForm({
    super.key,
    required this.formKey,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<AdditionalInfoForm> createState() => _AdditionalInfoFormState();
}

class _AdditionalInfoFormState extends State<AdditionalInfoForm> {
  late TextEditingController _descriptionController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _gstNumberController;
  late TextEditingController _panNumberController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _descriptionController = TextEditingController(text: widget.initialData['description'] ?? '');
    _registrationNumberController = TextEditingController(text: widget.initialData['registrationNumber'] ?? '');
    _licenseNumberController = TextEditingController(text: widget.initialData['licenseNumber'] ?? '');
    _gstNumberController = TextEditingController(text: widget.initialData['gstNumber'] ?? '');
    _panNumberController = TextEditingController(text: widget.initialData['panNumber'] ?? '');

    // Add listeners
    _descriptionController.addListener(_updateData);
    _registrationNumberController.addListener(_updateData);
    _licenseNumberController.addListener(_updateData);
    _gstNumberController.addListener(_updateData);
    _panNumberController.addListener(_updateData);

    // Initial data update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });
  }

  void _updateData() {
    widget.onDataChanged({
      'description': _descriptionController.text,
      'registrationNumber': _registrationNumberController.text,
      'licenseNumber': _licenseNumberController.text,
      'gstNumber': _gstNumberController.text,
      'panNumber': _panNumberController.text,
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
              'Additional Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B894),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide additional details and legal information',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Center Description',
              hint: 'Write a brief description about your coaching center, its mission, and what makes it unique...',
              icon: Icons.description,
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // Legal Information Section
            _buildSectionTitle('Legal Information'),
            const SizedBox(height: 16),

            // Registration Number
            _buildTextField(
              controller: _registrationNumberController,
              label: 'Registration Number',
              hint: 'Enter business registration number',
              icon: Icons.business_center,
            ),
            const SizedBox(height: 20),

            // License Number
            _buildTextField(
              controller: _licenseNumberController,
              label: 'License Number',
              hint: 'Enter educational license number',
              icon: Icons.verified,
            ),
            const SizedBox(height: 20),

            // GST Number
            _buildTextField(
              controller: _gstNumberController,
              label: 'GST Number',
              hint: 'Enter GST registration number',
              icon: Icons.receipt,
            ),
            const SizedBox(height: 20),

            // PAN Number
            _buildTextField(
              controller: _panNumberController,
              label: 'PAN Number',
              hint: 'Enter PAN number',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 32),

            // Terms and Conditions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00B894).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF00B894),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B894),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Your registration will be reviewed by our admin team\n'
                    '• You will receive an email notification once approved\n'
                    '• All information provided should be accurate and verifiable\n'
                    '• You may be asked to provide supporting documents',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Terms Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF00B894),
                ),
                Expanded(
                  child: Text(
                    'I agree to the Terms and Conditions and Privacy Policy. I confirm that all information provided is accurate and I have the authority to register this coaching center.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
          maxLines: maxLines,
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
    _descriptionController.dispose();
    _registrationNumberController.dispose();
    _licenseNumberController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }
}
