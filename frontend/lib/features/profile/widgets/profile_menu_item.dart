import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_action_tile.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    return AppActionTile(
      title: title,
      onTap: onTap,
      leadingIcon: icon,
      isDestructive: isDestructive,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
