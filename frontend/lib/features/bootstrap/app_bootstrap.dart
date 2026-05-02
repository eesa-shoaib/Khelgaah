import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/utils/role_home.dart';
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
  Future<bool>? _shouldShowLoading;
  AppController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= AppScope.of(context);
    _shouldShowLoading ??= _resolveFirstLaunch();
  }

  Future<bool> _resolveFirstLaunch() async {
    await _controller!.initialize();
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
          return _controller!.isAuthenticated
              ? buildHomeForRole(_controller!.session!.user)
              : const AuthScreen();
        }

        return _LaunchSequence(controller: _controller!);
      },
    );
  }
}

class _LaunchSequence extends StatefulWidget {
  const _LaunchSequence({required this.controller});

  final AppController controller;

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
      child: _showAuth
          ? (widget.controller.isAuthenticated
                ? buildHomeForRole(widget.controller.session!.user)
                : const AuthScreen())
          : const FirstLaunchLoadingScreen(),
    );
  }
}
