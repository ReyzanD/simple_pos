import 'package:flutter/material.dart';
import 'package:simple_pos/core/widgets/shimmer_loading.dart';
import 'package:simple_pos/core/utils/responsive_helper.dart';

/// Shimmer loading grid for showing loading state in POS screen
class POSShimmerLoadingGrid extends StatelessWidget {
  const POSShimmerLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getCardSpacing(context),
        0,
        ResponsiveHelper.getCardSpacing(context),
        ResponsiveHelper.isVerySmallScreen(context) ? 80 : 100,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
        crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
        mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerProductGridItem(),
    );
  }
}
