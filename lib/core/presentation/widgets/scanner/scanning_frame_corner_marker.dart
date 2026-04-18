import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Corner marker for scanning frame
class ScanningFrameCornerMarker extends StatelessWidget {
  const ScanningFrameCornerMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
