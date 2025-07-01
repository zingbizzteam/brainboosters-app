import 'package:flutter/material.dart';

class NameStep extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const NameStep({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "What's your name?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person),
            ),
            style: const TextStyle(fontSize: 18),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            style: const TextStyle(fontSize: 18),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }
}
