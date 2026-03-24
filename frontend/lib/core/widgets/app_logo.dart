import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final TextAlign textAlign;

  const AppLogo({
    super.key,
    this.width = 220,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        'KhelGaah',
        textAlign: textAlign,
        style: const TextStyle(
          color: AppTheme.orangePrimary,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: -1.5,
          shadows: [
            Shadow(
              color: AppTheme.redPrimary,
              offset: Offset(-2, 2),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
