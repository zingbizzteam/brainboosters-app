// screens/authentication/coaching_center/widgets/basic_info_form.dart
import 'package:flutter/material.dart';

class BasicInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const BasicInfoForm({
    super.key,
    required this.formKey,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<BasicInfoForm> createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfoForm> {
  late TextEditingController _centerNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _foundersNameController;
  late TextEditingController _designationController;
  int? _establishmentYear;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _centerNameController = TextEditingController(text: widget.initialData['centerName'] ?? '');
    _contactPersonController = TextEditingController(text: widget.initialData['contactPerson'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _passwordController = TextEditingController(text: widget.initialData['password'] ?? '');
    _foundersNameController = TextEditingController(text: widget.initialData['foundersName'] ?? '');
    _designationController = TextEditingController(text: widget.initialData['designation'] ?? '');
    _establishmentYear = widget.initialData['establishmentYear'];

    // Add listeners
    _centerNameController.addListener(_updateData);
    _contactPersonController.addListener(_updateData);
    _emailController.addListener(_updateData);
    _passwordController.addListener(_updateData);
    _foundersNameController.addListener(_updateData);
    _designationController.addListener(_updateData);

    // Initial data update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });
  }

  void _updateData() {
    widget.onDataChanged({
      'centerName': _centerNameController.text,
      'contactPerson': _contactPersonController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'foundersName': _foundersNameController.text,
      'designation': _designationController.text,
      'establishmentYear': _establishmentYear,
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
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B894),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about your coaching center',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Center Name
            _buildTextField(
              controller: _centerNameController,
              label: 'Coaching Center Name *',
              hint: 'Enter your coaching center name',
              icon: Icons.business,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Center name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Contact Person
            _buildTextField(
              controller: _contactPersonController,
              label: 'Contact Person Name *',
              hint: 'Enter contact person name',
              icon: Icons.person,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Contact person name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Designation
            _buildTextField(
              controller: _designationController,
              label: 'Designation',
              hint: 'e.g., Director, Principal, Manager',
              icon: Icons.work,
            ),
            const SizedBox(height: 20),

            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Admin Email *',
              hint: 'Enter admin email address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password
            _buildTextField(
              controller: _passwordController,
              label: 'Password *',
              hint: 'Create a strong password',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Password is required';
                }
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Founders Name
            _buildTextField(
              controller: _foundersNameController,
              label: 'Founder\'s Name',
              hint: 'Enter founder\'s name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // Establishment Year
            _buildDropdownField(
              label: 'Establishment Year',
              hint: 'Select establishment year',
              icon: Icons.calendar_today,
              value: _establishmentYear,
              items: List.generate(50, (index) {
                final year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _establishmentYear = value;
                });
                _updateData();
              },
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
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF00B894)),
            suffixIcon: suffixIcon,
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

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
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
        DropdownButtonFormField<int>(
          value: value,
          items: items,
          onChanged: onChanged,
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
    _centerNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _foundersNameController.dispose();
    _designationController.dispose();
    super.dispose();
  }
}
