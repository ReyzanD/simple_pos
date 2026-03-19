import 'package:flutter/material.dart';
import 'shimmer_loading.dart';
import 'modern_card.dart';

/// Helper widget that shows a list of shimmer loading items
/// Useful for displaying loading skeletons while data is being fetched
class ListItemShimmer extends StatelessWidget {
  final int itemCount;

  const ListItemShimmer({
    this.itemCount = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoading(
          child: ModernCard(
            child: Container(
              height: 72,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}
