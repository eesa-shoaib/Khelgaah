import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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
    return ListTile(
      contentPadding: EdgeInsetsGeometry.only(left: 20, right: 20),
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.orangePrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.orangePrimary,
      ),
    );
  }
}
