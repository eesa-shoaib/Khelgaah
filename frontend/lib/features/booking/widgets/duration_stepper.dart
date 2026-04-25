import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_theme.dart';

class DurationStepper extends StatelessWidget {
  final int duration;
  final int minDuration;
  final int maxDuration;
  final int step;
  final ValueChanged<int> onChanged;

  const DurationStepper({
    super.key,
    required this.duration,
    this.minDuration = 30,
    this.maxDuration = 180,
    this.step = 30,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              '$duration MIN',
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: duration > minDuration
                    ? () {
                        HapticFeedback.selectionClick();
                        onChanged(duration - step);
                      }
                    : null,
              ),
              _StepperButton(
                icon: Icons.add,
                onTap: duration < maxDuration
                    ? () {
                        HapticFeedback.selectionClick();
                        onChanged(duration + step);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 48,
          child: Icon(
            icon,
            color: onTap != null ? AppTheme.primary : AppTheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
