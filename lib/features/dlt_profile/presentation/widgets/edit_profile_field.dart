import 'package:flutter/material.dart';

class EditProfileField extends StatelessWidget {
  const EditProfileField({
    required this.label,
    required this.initialValue,
    super.key,
  });
  final String label;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
