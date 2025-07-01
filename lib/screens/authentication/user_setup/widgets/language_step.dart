import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LanguageStep extends StatefulWidget {
  final String? selectedLanguage;
  final ValueChanged<String?> onChanged;

  const LanguageStep({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  State<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends State<LanguageStep> {
  List<String> _languages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      final response = await Supabase.instance.client
          .from('app_config')
          .select('config_value')
          .eq('config_key', 'supported_languages')
          .eq('is_active', true)
          .single();

      final languageCodes = List<String>.from(response['config_value']);
      
      // Map language codes to display names
      final languageMap = {
        'en': 'English',
        'ta': 'Tamil',
        'hi': 'Hindi',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'zh': 'Chinese',
        'ja': 'Japanese',
        'ko': 'Korean',
        'ar': 'Arabic',
      };

      setState(() {
        _languages = languageCodes
            .map((code) => languageMap[code] ?? code.toUpperCase())
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading languages: $e');
      // Fallback to default languages
      setState(() {
        _languages = ['English', 'Tamil', 'Hindi'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          
          if (_isLoading)
            const CircularProgressIndicator()
          else
            DropdownButtonFormField<String>(
              value: widget.selectedLanguage,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.language),
              ),
              items: _languages
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: widget.onChanged,
            ),
        ],
      ),
    );
  }
}
