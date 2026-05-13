import 'package:flutter/material.dart';

import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({super.key, 
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorScheme.primary),
      title: Text(title, style: context.titleMedium),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}