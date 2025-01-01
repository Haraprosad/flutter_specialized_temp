import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';

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