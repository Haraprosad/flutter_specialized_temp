import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/theme/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/features/profile/presentation/widgets/edit_profile_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: context.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.mediumW),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.largeH),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: context.colorScheme.primary,
                  child: Text('JD', style: context.headlineLarge?.copyWith(
                    color: context.colorScheme.onPrimary,
                  )),
                ),
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: context.colorScheme.secondary,
                  child: Icon(Icons.camera_alt,
                      size: 20.r,
                      color: context.colorScheme.onSecondary),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.largeH),
            EditProfileField(
              label: 'Name',
              initialValue: 'John Doe',
            ),
            SizedBox(height: AppSpacing.mediumH),
            EditProfileField(
              label: 'Email',
              initialValue: 'john.doe@example.com',
            ),
            SizedBox(height: AppSpacing.mediumH),
            EditProfileField(
              label: 'Phone',
              initialValue: '+1 234 567 890',
            ),
            SizedBox(height: AppSpacing.largeH),
            ElevatedButton(
              onPressed: () {},
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
