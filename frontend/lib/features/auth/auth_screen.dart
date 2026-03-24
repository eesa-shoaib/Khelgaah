import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/main_layout.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;

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
                  color: AppTheme.orangeAccent,
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
                  color: AppTheme.textPrimary,
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
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.orangePrimary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSignIn) ...[
                      const AppTextField(
                        label: 'Full Name',
                        hintText: 'Eesa Shoaib',
                      ),
                      const SizedBox(height: 16),
                    ],
                    const AppTextField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      obscureText: true,
                    ),
                    if (!_isSignIn) ...[
                      const SizedBox(height: 16),
                      const AppTextField(
                        label: 'Phone',
                        hintText: '+92 300 1234567',
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ParallelogramButton(
                      text: _isSignIn ? 'Enter KhelGaah' : 'Create Account',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainLayout()),
                        );
                      },
                      fullWidth: true,
                      icon: Icons.arrow_forward,
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
