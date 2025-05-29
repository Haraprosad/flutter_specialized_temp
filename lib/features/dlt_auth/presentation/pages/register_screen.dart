// register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_sizes.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_spacing.dart';
import 'package:flutter_specialized_temp/core/theme/extensions/theme_extensions.dart';
import 'package:flutter_specialized_temp/core/theme/typography/text_theme_ext.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      // TODO: Implement your registration logic here
      print('Full Name: ${_fullNameController.text}');
      print('Email: ${_emailController.text}');
      print('Phone: ${_phoneController.text}');
      print('Password: ${_passwordController.text}');
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the terms and conditions',
            style: context.bodyMedium?.copyWith(color: context.colors.surface),
          ),
          backgroundColor: context.colors.alert,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.colors.textPrimary,
            size: AppSizes.iconLg,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.lgPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              AppSpacing.xlHeight,
              _buildRegistrationForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: context.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        AppSpacing.smHeight,
        Text(
          'Please fill in the form to continue',
          style: context.bodyLarge?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return context.cardContainer(
      child: Padding(
        padding: AppSpacing.lgPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFullNameField(),
              AppSpacing.mdHeight,
              _buildEmailField(),
              AppSpacing.mdHeight,
              _buildPhoneField(),
              AppSpacing.mdHeight,
              _buildPasswordField(),
              AppSpacing.mdHeight,
              _buildConfirmPasswordField(),
              AppSpacing.lgHeight,
              _buildTermsCheckbox(),
              AppSpacing.xlHeight,
              _buildRegisterButton(),
              AppSpacing.lgHeight,
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      textCapitalization: TextCapitalization.words,
      style: context.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Full Name',
        labelStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
        hintText: 'Enter your full name',
        hintStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          color: context.colors.textSecondary,
          size: AppSizes.iconMd,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().split(' ').length < 2) {
          return 'Please enter your full name (first & last name)';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: context.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
        hintText: 'Enter your email',
        hintStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: context.colors.textSecondary,
          size: AppSizes.iconMd,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: context.bodyLarge,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
        hintText: 'Enter your phone number',
        hintStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          Icons.phone_outlined,
          color: context.colors.textSecondary,
          size: AppSizes.iconMd,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.length < 10) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: context.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
        hintText: 'Enter your password',
        hintStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: context.colors.textSecondary,
          size: AppSizes.iconMd,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: context.colors.textSecondary,
            size: AppSizes.iconMd,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (!value.contains(RegExp(r'[A-Z]'))) {
          return 'Password must contain at least one uppercase letter';
        }
        if (!value.contains(RegExp(r'[0-9]'))) {
          return 'Password must contain at least one number';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: context.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        labelStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
        hintText: 'Confirm your password',
        hintStyle: context.bodyMedium?.copyWith(
          color: context.colors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: context.colors.textSecondary,
          size: AppSizes.iconMd,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: context.colors.textSecondary,
            size: AppSizes.iconMd,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value!;
            });
          },
          activeColor: context.colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: context.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: context.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: context.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: context.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: AppSizes.buttonLarge,
      child: ElevatedButton(
        onPressed: _handleRegister,
        child: Text(
          'Create Account',
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: context.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            context.pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colors.primary,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          ),
          child: Text(
            'Sign In',
            style: context.bodyMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
