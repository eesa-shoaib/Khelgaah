import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/auth/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'first_launch_loading_screen.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  static const _firstLaunchKey = 'has_seen_launch_loading';
  late final Future<bool> _shouldShowLoading;

  @override
  void initState() {
    super.initState();
    _shouldShowLoading = _resolveFirstLaunch();
  }

  Future<bool> _resolveFirstLaunch() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeenLoading = preferences.getBool(_firstLaunchKey) ?? false;

    if (!hasSeenLoading) {
      await preferences.setBool(_firstLaunchKey, true);
    }

    return true; // Always show loading for testing
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldShowLoading,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.expand(child: ColoredBox(color: Colors.black));
        }

        if (!snapshot.data!) {
          return const AuthScreen();
        }

        return const _LaunchSequence();
      },
    );
  }
}

class _LaunchSequence extends StatefulWidget {
  const _LaunchSequence();

  @override
  State<_LaunchSequence> createState() => _LaunchSequenceState();
}

class _LaunchSequenceState extends State<_LaunchSequence> {
  bool _showAuth = false;

  @override
  void initState() {
    super.initState();
    unawaited(_completeSequence());
  }

  Future<void> _completeSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) {
      return;
    }

    setState(() {
      _showAuth = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showAuth ? const AuthScreen() : const FirstLaunchLoadingScreen(),
    );
  }
}
