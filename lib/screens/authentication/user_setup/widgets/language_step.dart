import 'package:flutter/material.dart';

class LanguageStep extends StatelessWidget {
  final String? selectedLanguage;
  final ValueChanged<String?> onChanged;

  const LanguageStep({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> languages = [
      'English',
      'Tamil',
      'Hindi',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Preferred Language",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            value: selectedLanguage,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.language),
            ),
            items: languages
                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
