import 'package:flutter/material.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/profile/profile_screen.dart';

class ProfileActionIcon extends StatelessWidget {
  const ProfileActionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        AppFeedback.haptic(AppFeedbackType.tap);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      icon: const Icon(Icons.person_outline, color: AppTheme.orangePrimary),
    );
  }
}
