import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorScheme.primary, size: 24.r),
      title: Text(title, style: context.titleMedium?.copyWith(fontSize: 16.sp)),
      trailing: Icon(Icons.chevron_right, size: 24.r),
      onTap: onTap,
    );
  }
}