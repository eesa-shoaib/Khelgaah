import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class AppRatingBadge extends StatelessWidget {
  final double rating;

  const AppRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.orangePrimary.withValues(alpha: 0.15),
        border: Border.all(color: AppTheme.orangePrimary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppTheme.orangeAccent, size: 12),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppTheme.orangeAccent,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
