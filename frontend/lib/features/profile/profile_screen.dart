import 'package:flutter/material.dart';
import 'package:frontend/features/profile/widgets/profile_header.dart';
import 'package:frontend/features/profile/widgets/profile_menu_item.dart';
import '../../core/theme/app_theme.dart';

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
            const Divider(color: AppTheme.orangePrimary),
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Booking History',
              onTap: () {},
              isDestructive: false,
            ),
            ProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
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

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to exit?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Logout', style: TextStyle(color: AppTheme.error)),
        ),
      ],
    ),
  );
}
