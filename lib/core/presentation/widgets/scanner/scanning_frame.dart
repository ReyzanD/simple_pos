import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/responsive_helper.dart';
import 'scanning_frame_corner_marker.dart';

/// Centered scanning frame overlay with corner markers
class ScanningFrame extends StatelessWidget {
  final String instruction;

  const ScanningFrame({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.getValue(
        context: context,
        mobile: 240,
        tablet: 280,
        desktop: 320,
      ),
      height: ResponsiveHelper.getValue(
        context: context,
        mobile: 240,
        tablet: 280,
        desktop: 320,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.8),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusXLarge),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Top corner markers
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getContainerPadding(context)),
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
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getContainerPadding(context)),
            child: Text(
              instruction,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
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
            padding: EdgeInsets.all(ResponsiveHelper.getContainerPadding(context)),
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
