import 'package:flutter/material.dart';

class EditProfileField extends StatelessWidget {
  final String label;
  final String initialValue;

  const EditProfileField({super.key, 
    required this.label,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}