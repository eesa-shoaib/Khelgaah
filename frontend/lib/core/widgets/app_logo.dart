import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Text(
        'KhelGaah',
        textAlign: textAlign,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: -1.5,
          shadows: [
            Shadow(
              color: colorScheme.primaryContainer,
              offset: Offset(-2, 2),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
