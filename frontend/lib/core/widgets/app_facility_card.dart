import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/widgets/app_rating_badge.dart';

class AppFacilityCard extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final VoidCallback onTap;
  final double height;

  const AppFacilityCard({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.onTap,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomPaint(
        size: Size.fromHeight(height),
        painter: _FacilityCardPainter(borderColor: colorScheme.primary),
        child: ClipPath(
          clipper: _FacilityCardClipper(),
          child: Material(
            color: colorScheme.surface,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      AppRatingBadge(rating: rating),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: colorScheme.primary,
                        size: 16,
                      ),
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

class _FacilityCardPainter extends CustomPainter {
  const _FacilityCardPainter({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const arrowTip = 20.0;
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width - arrowTip, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowTip, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw border
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _FacilityCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const arrowTip = 20.0;

    path.moveTo(0, 0);
    path.lineTo(size.width - arrowTip, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowTip, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
