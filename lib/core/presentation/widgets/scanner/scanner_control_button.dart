import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Scanner control button
class ScannerControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color? foregroundColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  const ScannerControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.foregroundColor,
    this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor ?? Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
