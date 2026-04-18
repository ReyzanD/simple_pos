import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/widgets/brutal_inputs.dart';
import '../../controllers/pos_controller.dart';

/// POS Search Bar - Product search functionality
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
      child: BrutalSearchField(
        hint: 'Cari produk...',
        controller: searchController,
        onChanged: (value) {
          controller.setSearchQuery(value);
        },
        backgroundColor: NeoBrutalTheme.surface,
      ),
    );
  }
}
