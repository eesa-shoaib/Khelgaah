import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.orangePrimary,
          child: Icon(Icons.person, size: 50, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}
