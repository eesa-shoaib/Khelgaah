import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_logo.dart';

class FirstLaunchLoadingScreen extends StatefulWidget {
  const FirstLaunchLoadingScreen({super.key});

  @override
  State<FirstLaunchLoadingScreen> createState() =>
      _FirstLaunchLoadingScreenState();
}

class _FirstLaunchLoadingScreenState extends State<FirstLaunchLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glow = Curves.easeInOut.transform(_controller.value);

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0A0A),
                  Color.lerp(
                    AppTheme.background,
                    AppTheme.redPrimary.withValues(alpha: 0.28),
                    glow,
                  )!,
                  AppTheme.background,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment(-0.9 + (glow * 0.25), -0.75),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.orangePrimary.withValues(alpha: 0.09),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.95 - (glow * 0.2), 0.82),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.redGlow.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: Offset(0, glow * -8),
                        child: const AppLogo(width: 250),
                      ),
                      const Spacer(),
                      const Text(
                        'LOCKING IN COURTS, LANES, AND YOUR NEXT SESSION.',
                        style: TextStyle(
                          color: AppTheme.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Preparing the live booking floor.',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Availability, timings, and your shortcuts are being staged for the first launch.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: AppTheme.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              AppTheme.orangePrimary,
                              AppTheme.orangeAccent,
                              glow,
                            )!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
