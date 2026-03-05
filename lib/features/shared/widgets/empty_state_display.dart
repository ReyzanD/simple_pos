import 'package:flutter/material.dart';
import '../../../../core/constants/ui_constants.dart';

/// Reusable widget for displaying empty state
class EmptyStateDisplay extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyStateDisplay({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                color: Colors.grey,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: UIConstants.spacingLarge),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
