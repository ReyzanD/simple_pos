import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'scanning_frame_corner_marker.dart';

/// Centered scanning frame overlay with corner markers
class ScanningFrame extends StatelessWidget {
  final String instruction;

  const ScanningFrame({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.8),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Top corner markers
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ScanningFrameCornerMarker(),
                ScanningFrameCornerMarker(),
              ],
            ),
          ),

          // Scan instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              instruction,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Bottom corner markers
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ScanningFrameCornerMarker(),
                ScanningFrameCornerMarker(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
