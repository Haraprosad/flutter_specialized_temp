// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(RouteNames.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.mdPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.smHeight,
                _buildHeader(),
                AppSpacing.mdHeight,
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          padding: AppSpacing.xlPadding,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outlined,
            size: AppDimensions.iconXxl * 1.5,
            color: context.colors.primary,
          ),
        ),
        AppSpacing.mdHeight,
        // Welcome Text
        Text(
          'Welcome Back!',
          style: context.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.smHeight,
        Text(
          'Sign in to continue to your account',
          style: context.bodyLarge?.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: AppCardStyles.elevated(context.colors),
      child: Padding(
        padding: AppSpacing.lgPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEmailField(),
              AppSpacing.mdHeight,
              _buildPasswordField(),
              AppSpacing.mdHeight,
              _buildRememberMeRow(),
              AppSpacing.xlHeight,
              _buildLoginButton(),
              AppSpacing.lgHeight,
              _buildOrDivider(),
              AppSpacing.lgHeight,
              _buildSocialLoginButtons(),
              AppSpacing.lgHeight,
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
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
          color: context.colors.textSecondary.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: context.colors.textSecondary,
          size: AppDimensions.iconMd,
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
          color: context.colors.textSecondary.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: context.colors.textSecondary,
          size: AppDimensions.iconMd,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: context.colors.textSecondary,
            size: AppDimensions.iconMd,
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
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value!;
                  });
                },
                activeColor: context.colors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                'Remember me',
                style: context.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO(niloy): Implement forgot password
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colors.primary,
            padding: AppSpacing.smPadding,
          ),
          child: Text(
            'Forgot Password?',
            style: context.bodyMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: AppDimensions.buttonLarge,
      child: ElevatedButton(
        onPressed: _handleLogin,
        child: Text(
          'Sign In',
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.colors.textSecondary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: AppSpacing.mdHorizontal,
          child: Text(
            'OR',
            style: context.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.colors.textSecondary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialLoginButton(
          icon: Icons.g_mobiledata,
          onPressed: () {
            // TODO(niloy): Implement Google login
          },
        ),
        _buildSocialLoginButton(
          icon: Icons.facebook,
          onPressed: () {
            // TODO(niloy): Implement Facebook login
          },
        ),
        _buildSocialLoginButton(
          icon: Icons.apple,
          onPressed: () {
            // TODO(niloy): Implement Apple login
          },
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: AppSpacing.xsHorizontal,
        child: IconButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: AppSpacing.mdVertical,
            side: BorderSide(
              color: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          icon: Icon(
            icon,
            size: AppDimensions.iconLg,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: context.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            context.pushNamed(RouteNames.register);
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colors.primary,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          ),
          child: Text(
            'Sign Up',
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
