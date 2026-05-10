import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/features/auth/auth_screen.dart';
import 'package:frontend/features/profile/widgets/profile_header.dart';
import 'package:frontend/features/profile/widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppScope.of(context).session;
    final name = session?.user.fullName ?? 'Player';
    final email = session?.user.email ?? 'Not signed in';
    final role = session?.user.role ?? 'customer';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ProfileHeader(name: name, email: email),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.outlineVariant),
            if (role == 'venue_owner')
              ProfileMenuItem(
                icon: Icons.dashboard,
                title: 'Owner Dashboard',
                onTap: () => _navigateToOwnerDashboard(context),
                isDestructive: false,
              ),
            if (role == 'admin')
              ProfileMenuItem(
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                onTap: () => _navigateToAdminDashboard(context),
                isDestructive: false,
              ),
            ProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _showSettingsDialog(context),
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

  void _navigateToOwnerDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/venue-owner');
  }

  void _navigateToAdminDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/admin');
  }

  void _showSettingsDialog(BuildContext context) {
    AppFeedback.haptic(AppFeedbackType.tap);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Notifications, preferred sports, and payment methods will be managed here.'),
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
            onPressed: () async {
              await AppScope.of(context).logout();
              if (!context.mounted) {
                return;
              }
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
}


