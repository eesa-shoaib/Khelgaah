import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/bootstrap/app_bootstrap.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Khelgaah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppBootstrap(),
      ),
    );
  }
}
