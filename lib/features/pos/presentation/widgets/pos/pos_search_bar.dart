import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/widgets/brutal_inputs.dart';
import '../../controllers/pos_controller.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Improved POS Search Bar with fixed height alignment
///
/// Changes:
/// - Fixed height: 44 for alignment with filter controls
/// - Consistent padding and spacing
class POSSearchBar extends StatelessWidget {
  final POSController controller;
  final TextEditingController searchController;

  const POSSearchBar({
    super.key,
    required this.controller,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NeoBrutalTheme.spaceMD,
        NeoBrutalTheme.spaceSM,
        NeoBrutalTheme.spaceMD,
        NeoBrutalTheme.spaceSM,
      ),
      child: SizedBox(
        height: 44,
        child: BrutalSearchField(
          hint: AppLocalizations.of(context)!.product_search,
          controller: searchController,
          onChanged: (value) {
            controller.setSearchQuery(value);
          },
          backgroundColor: NeoBrutalTheme.getCardColor(context),
        ),
      ),
    );
  }
}
