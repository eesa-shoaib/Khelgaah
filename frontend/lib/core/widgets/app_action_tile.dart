import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const arrowTip = 20.0;

    path.moveTo(0, 0); // top-left (flat)
    path.lineTo(size.width - arrowTip, 0); // top-right before tip
    path.lineTo(size.width, size.height / 2); // arrow tip (right point)
    path.lineTo(size.width - arrowTip, size.height); // bottom-right before tip
    path.lineTo(0, size.height); // bottom-left (flat)
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AppActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isDestructive;
  final EdgeInsetsGeometry margin;

  const AppActionTile({
    super.key,
    required this.title,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon = Icons.arrow_forward_ios,
    this.isDestructive = false,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final titleColor = isDestructive ? colorScheme.error : colorScheme.onSurface;
    final borderColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return Padding(
      padding: margin,
      child: ClipPath(
        clipper: ArrowClipper(),
        child: Container(
          color: borderColor,
          padding: const EdgeInsets.all(1.2),
          child: ClipPath(
            clipper: ArrowClipper(),
            child: Material(
              color: colorScheme.surface,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 32,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, color: accentColor),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon, size: 18, color: accentColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
