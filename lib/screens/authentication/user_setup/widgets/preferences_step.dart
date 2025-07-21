import 'package:flutter/material.dart';
import 'language_step.dart';
import 'goal_selection_step.dart';

class PreferencesStep extends StatelessWidget {
  final String? selectedLanguage;
  final List<String> selectedGoals;
  final ValueChanged<String?> onLanguageChanged;
  final void Function(String) onGoalToggle;

  const PreferencesStep({
    super.key,
    required this.selectedLanguage,
    required this.selectedGoals,
    required this.onLanguageChanged,
    required this.onGoalToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          const Text(
            'Learning Preferences',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Language selection
          LanguageStep(
            selectedLanguage: selectedLanguage,
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 24),

          // Course selection - Fixed height container
          SizedBox(
            height: 500,
            child: GoalSelectionStep(
              selectedGoals: selectedGoals,
              onCourseToggle: onGoalToggle,
            ),
          ),

          // Bottom padding
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
