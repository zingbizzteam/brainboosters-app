import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PersonalInfoStep extends StatelessWidget {
  final String? fullPhoneNumber;
  final String phoneIsoCode;
  final DateTime? selectedDate;
  final String? selectedGender;
  final ValueChanged<String?> onPhoneChanged;
  final ValueChanged<String> onIsoCodeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String?> onGenderChanged;

  const PersonalInfoStep({
    super.key,
    required this.fullPhoneNumber,
    required this.phoneIsoCode,
    required this.selectedDate,
    required this.selectedGender,
    required this.onPhoneChanged,
    required this.onIsoCodeChanged,
    required this.onDateChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Phone
            IntlPhoneField(
              decoration: InputDecoration(
                labelText: 'Phone number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              initialCountryCode: phoneIsoCode,
              onChanged: (phone) {
                onPhoneChanged(phone.completeNumber);
                onIsoCodeChanged(phone.countryISOCode);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Date of Birth
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) onDateChanged(date);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null ? 'Select Date of Birth' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Gender
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.person),
              ),
              items: ['male', 'female', 'other']
                  .map((gender) => DropdownMenuItem(value: gender, child: Text(gender.toUpperCase())))
                  .toList(),
              onChanged: onGenderChanged,
            ),
          ],
        ),
      ),
    );
  }
}
