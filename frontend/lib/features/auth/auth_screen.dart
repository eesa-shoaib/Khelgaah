import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/main_layout.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Email and password are required.');
      return;
    }

    if (!_isSignIn) {
      if (_fullNameController.text.trim().isEmpty) {
        _showError('Full name is required.');
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        _showError('Phone is required.');
        return;
      }
    }

    final controller = AppScope.of(context);
    setState(() => _isSubmitting = true);

    try {
      if (_isSignIn) {
        await controller.signIn(email: email, password: password);
      } else {
        await controller.signUp(
          fullName: _fullNameController.text.trim(),
          email: email,
          password: password,
          phone: _phoneController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      AppFeedback.haptic(AppFeedbackType.success);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Could not reach the backend.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    AppFeedback.pulseMessage(
      context,
      message: message,
      icon: Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Center(child: AppLogo(width: 260)),
              const SizedBox(height: 20),
              const Text(
                'BOOK YOUR GAME.',
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isSignIn
                    ? 'Sign in and keep your schedule tight.'
                    : 'Create your account and claim your next slot.',
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ParallelogramButton(
                      text: 'Sign In',
                      onPressed: () => setState(() => _isSignIn = true),
                      variant: _isSignIn
                          ? ParallelogramButtonVariant.primary
                          : ParallelogramButtonVariant.surface,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ParallelogramButton(
                      text: 'Sign Up',
                      onPressed: () => setState(() => _isSignIn = false),
                      variant: !_isSignIn
                          ? ParallelogramButtonVariant.primary
                          : ParallelogramButtonVariant.surface,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  border: Border.all(color: AppTheme.primary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSignIn) ...[
                      AppTextField(
                        label: 'Full Name',
                        hintText: 'Eesa Shoaib',
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    if (!_isSignIn) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone',
                        hintText: '+92 300 1234567',
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ParallelogramButton(
                      text: _isSubmitting
                          ? 'Connecting...'
                          : (_isSignIn ? 'Enter KhelGaah' : 'Create Account'),
                      onPressed: _submit,
                      fullWidth: true,
                      icon: Icons.arrow_forward,
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const BookingSummaryCard(
                title: 'What you get',
                subtitle:
                    'Fast booking, saved time slots, and one place to track all your matches.',
                meta: 'TENNIS  POOL  GYM  BADMINTON',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
