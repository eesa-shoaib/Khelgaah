import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParallelogramButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ParallelogramButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: ClipPath(
        clipper: ParallelogramClipper(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          color: Theme.of(context).colorScheme.primary,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const skew = 10.0;

    return Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
