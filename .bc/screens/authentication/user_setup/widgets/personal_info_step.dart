import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PersonalInfoStep extends StatelessWidget {
  final String? fullPhoneNumber;
  final String phoneIsoCode;
  final DateTime? selectedDate;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onIsoCodeChanged;
  final ValueChanged<DateTime> onDateChanged;

  const PersonalInfoStep({
    super.key,
    required this.fullPhoneNumber,
    required this.phoneIsoCode,
    required this.selectedDate,
    required this.onPhoneChanged,
    required this.onIsoCodeChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Let's start with your phone number",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            initialCountryCode: phoneIsoCode,
            style: const TextStyle(fontSize: 18),
            onChanged: (phone) {
              onPhoneChanged(phone.completeNumber);
              onIsoCodeChanged(phone.countryISOCode);
            },
            validator: (phone) => phone == null || phone.number.length < 6
                ? 'Enter valid number'
                : null,
          ),
          const SizedBox(height: 24),
          const Text(
            "Date of Birth",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
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
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate == null
                        ? 'Select Date'
                        : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
