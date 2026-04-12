import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/features/auth/auth_screen.dart';
import 'package:frontend/features/profile/widgets/profile_header.dart';
import 'package:frontend/features/profile/widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const ProfileHeader(name: 'Eesa', email: 'eesa.shoaib@gmail.com'),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.divider),
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Booking History',
              onTap: () => _showInfoDialog(
                context,
                title: 'Booking History',
                description:
                    'Recent bookings: Badminton Court 02, Gym Strength Block, and Swimming Pool Lane 03.',
              ),
              isDestructive: false,
            ),
            ProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _showInfoDialog(
                context,
                title: 'Settings',
                description:
                    'Notifications, preferred sports, and payment methods will be managed here.',
              ),
              isDestructive: false,
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

void _showInfoDialog(
  BuildContext context, {
  required String title,
  required String description,
}) {
  AppFeedback.haptic(AppFeedbackType.tap);
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        ParallelogramButton(
          onPressed: () => Navigator.pop(context),
          text: 'Close',
          variant: ParallelogramButtonVariant.surface,
        ),
      ],
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  AppFeedback.haptic(AppFeedbackType.tap);
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to exit?'),
      actions: [
        ParallelogramButton(
          onPressed: () => Navigator.pop(context),
          text: 'Cancel',
          variant: ParallelogramButtonVariant.surface,
        ),
        ParallelogramButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
          },
          text: 'Logout',
          variant: ParallelogramButtonVariant.destructive,
        ),
      ],
    ),
  );
}
