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
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.orangePrimary, width: 1.4),
          ),
          child: const Icon(
            Icons.person,
            size: 50,
            color: AppTheme.orangePrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(email, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}
