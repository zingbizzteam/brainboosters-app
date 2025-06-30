import 'package:flutter/material.dart';

class LanguageStepWidget extends StatelessWidget {
  final String? selectedLanguage;
  final ValueChanged<String?> onChanged;

  const LanguageStepWidget({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> languages = ['English', 'Tamil', 'Hindi'];

    return DropdownButtonFormField<String>(
      value: selectedLanguage,
      decoration: const InputDecoration(
        labelText: 'Preferred Language',
        prefixIcon: Icon(Icons.language),
        border: OutlineInputBorder(),
      ),
      items: languages
          .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a language';
        }
        return null;
      },
    );
  }
}
