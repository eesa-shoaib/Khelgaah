import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_selectable_tile.dart';

class TimeSlotItem extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  const TimeSlotItem({
    super.key,
    required this.time,
    required this.isSelected,
    this.isAvailable = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSelectableTile(
      label: time,
      isSelected: isSelected,
      isAvailable: isAvailable,
      onTap: onTap,
    );
  }
}
