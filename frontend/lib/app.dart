import 'package:flutter/material.dart';
import 'package:frontend/features/main_layout.dart';
import 'core/theme/app_theme.dart';
import 'features/main_layout.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Booking App',
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}
