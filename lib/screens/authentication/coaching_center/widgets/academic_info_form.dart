// screens/authentication/coaching_center/widgets/academic_info_form.dart
import 'package:flutter/material.dart';

class AcademicInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AcademicInfoForm({
    super.key,
    required this.formKey,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<AcademicInfoForm> createState() => _AcademicInfoFormState();
}

class _AcademicInfoFormState extends State<AcademicInfoForm> {
  late TextEditingController _admissionProcessController;
  late TextEditingController _averageFeesController;

  String? _selectedCategory;
  late List<String> _selectedSpecializations;
  late List<String> _selectedTeachingModes;
  late List<String> _selectedLanguages;
  late List<String> _selectedTeachingMethods;
  late List<String> _selectedExamsOffered;
  late List<String> _selectedBatchTimings;

  final List<String> _categories = [
    'Engineering Entrance',
    'Medical Entrance',
    'Competitive Exams',
    'School Education',
    'Professional Courses',
    'Language Learning',
    'Skill Development',
  ];

  final List<String> _specializations = [
    'JEE Preparation',
    'NEET Preparation',
    'UPSC Preparation',
    'SSC Preparation',
    'Banking Exams',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Computer Science',
    'Data Science',
    'Programming',
  ];

  final List<String> _teachingModes = [
    'online',
    'offline',
    'hybrid',
  ];

  final List<String> _languages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
  ];

  final List<String> _teachingMethods = [
    'Interactive Learning',
    'Problem Solving',
    'Mock Tests',
    'Doubt Clearing',
    'Group Discussions',
    'Practical Sessions',
    'Case Studies',
    'Project Based',
  ];

  final List<String> _examsOffered = [
    'JEE Main',
    'JEE Advanced',
    'NEET',
    'AIIMS',
    'BITSAT',
    'UPSC',
    'SSC CGL',
    'Banking PO',
    'GATE',
    'CAT',
    'CLAT',
    'State Board',
    'CBSE',
    'ICSE',
  ];

  final List<String> _batchTimings = [
    '6:00 AM - 8:00 AM',
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
    '6:00 PM - 8:00 PM',
    '8:00 PM - 10:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _admissionProcessController = TextEditingController(text: widget.initialData['admissionProcess'] ?? '');
    _averageFeesController = TextEditingController(text: widget.initialData['averageFees']?.toString() ?? '');

    // Initialize lists with existing data
    _selectedCategory = widget.initialData['category'];
    _selectedSpecializations = List<String>.from(widget.initialData['specializations'] ?? []);
    _selectedTeachingModes = List<String>.from(widget.initialData['teachingModes'] ?? ['offline']);
    _selectedLanguages = List<String>.from(widget.initialData['languages'] ?? ['English']);
    _selectedTeachingMethods = List<String>.from(widget.initialData['teachingMethods'] ?? []);
    _selectedExamsOffered = List<String>.from(widget.initialData['examsOffered'] ?? []);
    _selectedBatchTimings = List<String>.from(widget.initialData['batchTimings'] ?? []);

    // Add listeners
    _admissionProcessController.addListener(_updateData);
    _averageFeesController.addListener(_updateData);

    // Initial data update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });
  }

  void _updateData() {
    widget.onDataChanged({
      'category': _selectedCategory,
      'specializations': _selectedSpecializations,
      'teachingModes': _selectedTeachingModes,
      'languages': _selectedLanguages,
      'teachingMethods': _selectedTeachingMethods,
      'examsOffered': _selectedExamsOffered,
      'batchTimings': _selectedBatchTimings,
      'admissionProcess': _admissionProcessController.text,
      'averageFees': double.tryParse(_averageFeesController.text) ?? 0,
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
              'Academic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B894),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide details about your courses and teaching',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Category
            _buildDropdownField(
              label: 'Primary Category *',
              hint: 'Select your main category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _updateData();
              },
            ),
            const SizedBox(height: 24),

            // Specializations
            _buildMultiSelectField(
              'Specializations',
              'Select your areas of expertise',
              _specializations,
              _selectedSpecializations,
            ),
            const SizedBox(height: 24),

            // Teaching Modes
            _buildMultiSelectField(
              'Teaching Modes',
              'How do you conduct classes?',
              _teachingModes,
              _selectedTeachingModes,
            ),
            const SizedBox(height: 24),

            // Languages
            _buildMultiSelectField(
              'Languages',
              'Languages you teach in',
              _languages,
              _selectedLanguages,
            ),
            const SizedBox(height: 24),

            // Teaching Methods
            _buildMultiSelectField(
              'Teaching Methods',
              'Your teaching approaches',
              _teachingMethods,
              _selectedTeachingMethods,
            ),
            const SizedBox(height: 24),

            // Exams Offered
            _buildMultiSelectField(
              'Exams/Courses Offered',
              'Which exams do you prepare students for?',
              _examsOffered,
              _selectedExamsOffered,
            ),
            const SizedBox(height: 24),

            // Batch Timings
            _buildMultiSelectField(
              'Available Batch Timings',
              'When do you conduct classes?',
              _batchTimings,
              _selectedBatchTimings,
            ),
            const SizedBox(height: 24),

            // Average Fees
            _buildTextField(
              controller: _averageFeesController,
              label: 'Average Course Fees (₹)',
              hint: 'Enter average fees per course',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Admission Process
            _buildTextField(
              controller: _admissionProcessController,
              label: 'Admission Process',
              hint: 'Describe your admission process',
              icon: Icons.assignment,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildMultiSelectField(
    String title,
    String subtitle,
    List<String> options,
    List<String> selectedOptions,
  ) {
    return Column(
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
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
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
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
    _admissionProcessController.dispose();
    _averageFeesController.dispose();
    super.dispose();
  }
}
