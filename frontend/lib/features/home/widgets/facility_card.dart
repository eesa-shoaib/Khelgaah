import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FacilityCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const FacilityCard({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsetsGeometry.symmetric(vertical: 2, horizontal: 16),
        padding: const EdgeInsetsGeometry.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppTheme.orangePrimary,
            ),
          ],
        ),
      ),
    );
  }
}
