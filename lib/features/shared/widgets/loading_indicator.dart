import 'package:flutter/material.dart';
import '../../../../core/constants/ui_constants.dart';

/// Reusable loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: UIConstants.spacingMedium),
            Text(
              message!,
              style: const TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small loading indicator for inline use
class SmallLoadingIndicator extends StatelessWidget {
  const SmallLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20.0,
      height: 20.0,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
