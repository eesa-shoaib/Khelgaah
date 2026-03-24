import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_action_tile.dart';

class FacilityCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const FacilityCard({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppActionTile(
      title: name,
      onTap: onTap,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    );
  }
}
