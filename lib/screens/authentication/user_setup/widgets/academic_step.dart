import 'package:flutter/material.dart';

class AcademicStep extends StatelessWidget {
  final String? selectedGrade;
  final String? selectedBoard;
  final String? selectedInterest;
  final String? selectedState;
  final String? selectedCity;
  final TextEditingController schoolController;
  final TextEditingController parentNameController;
  final TextEditingController parentPhoneController;
  final TextEditingController parentEmailController;
  final List<Map<String, String>> gradeOptions;
  final List<Map<String, String>> boardOptions;
  final List<Map<String, String>> interestOptions;
  final Map<String, List<String>> statesAndCities;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onBoardChanged;
  final ValueChanged<String?> onInterestChanged;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;

  const AcademicStep({
    super.key,
    required this.selectedGrade,
    required this.selectedBoard,
    required this.selectedInterest,
    required this.selectedState,
    required this.selectedCity,
    required this.schoolController,
    required this.parentNameController,
    required this.parentPhoneController,
    required this.parentEmailController,
    required this.gradeOptions,
    required this.boardOptions,
    required this.interestOptions,
    required this.statesAndCities,
    required this.onGradeChanged,
    required this.onBoardChanged,
    required this.onInterestChanged,
    required this.onStateChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Education Level
          DropdownButtonFormField<String>(
            value: selectedGrade,
            decoration: InputDecoration(
              labelText: 'Education Level *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.school),
            ),
            items: gradeOptions.map((grade) {
              return DropdownMenuItem<String>(
                value: grade['value'],
                child: Text(grade['display']!),
              );
            }).toList(),
            onChanged: onGradeChanged,
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // Education Board
          DropdownButtonFormField<String>(
            value: selectedBoard,
            decoration: InputDecoration(
              labelText: 'Education Board',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.account_balance),
            ),
            items: boardOptions.map((board) {
              return DropdownMenuItem<String>(
                value: board['value'],
                child: Text(board['display']!),
              );
            }).toList(),
            onChanged: onBoardChanged,
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // Primary Interest
          DropdownButtonFormField<String>(
            value: selectedInterest,
            decoration: InputDecoration(
              labelText: 'Primary Interest',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.favorite),
            ),
            items: interestOptions.map((interest) {
              return DropdownMenuItem<String>(
                value: interest['value'],
                child: Text(interest['display']!),
              );
            }).toList(),
            onChanged: onInterestChanged,
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // State
          DropdownButtonFormField<String>(
            value: selectedState,
            decoration: InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.location_on),
            ),
            items: statesAndCities.keys.map((state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(state),
              );
            }).toList(),
            onChanged: onStateChanged,
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // City
          DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.location_city),
            ),
            items: selectedState != null
                ? statesAndCities[selectedState]!.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList()
                : [],
            onChanged: onCityChanged,
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // School Name
          TextField(
            controller: schoolController,
            decoration: InputDecoration(
              labelText: 'School/College Name (Optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Parent/Guardian Information (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: parentNameController,
            decoration: InputDecoration(
              labelText: 'Parent/Guardian Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: parentPhoneController,
            decoration: InputDecoration(
              labelText: 'Parent/Guardian Phone',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: parentEmailController,
            decoration: InputDecoration(
              labelText: 'Parent/Guardian Email',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
