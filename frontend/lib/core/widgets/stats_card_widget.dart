import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showBorder;

  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.subtitle,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? AppTheme.primary;
    final isInteractive = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: showBorder
                ? Border(
                    top: BorderSide(color: accent, width: 3),
                    bottom: BorderSide(
                      color: AppTheme.outlineVariant,
                      width: 1,
                    ),
                  )
                : null,
            boxShadow: isInteractive
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: accent, width: 1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(icon, size: 14, color: accent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
