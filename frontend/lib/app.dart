import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/bootstrap/app_bootstrap.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khelgaah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppBootstrap(),
    );
  }
}
