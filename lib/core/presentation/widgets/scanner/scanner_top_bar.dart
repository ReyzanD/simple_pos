import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Scanner top bar widget
class ScannerTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback onToggleFlash;
  final bool isFlashOn;

  const ScannerTopBar({
    super.key,
    required this.title,
    required this.onClose,
    required this.onToggleFlash,
    this.isFlashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onClose,
              padding: EdgeInsets.zero,
            ),
          ),

          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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

          // Flash toggle button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onToggleFlash,
              padding: EdgeInsets.zero,
              tooltip: 'Toggle Flash',
            ),
          ),
        ],
      ),
    );
  }
}
