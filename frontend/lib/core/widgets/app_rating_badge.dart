import 'package:flutter/material.dart';

class AppRatingBadge extends StatelessWidget {
  final double rating;

  const AppRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.15),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: colorScheme.tertiary, size: 12),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: colorScheme.tertiary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
