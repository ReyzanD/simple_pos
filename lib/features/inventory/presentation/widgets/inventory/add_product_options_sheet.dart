import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/widgets/brutal_widgets.dart';
import 'package:simple_pos/core/widgets/modern_button.dart';

/// Bottom sheet for adding products (manual or CSV import)
class AddProductOptionsSheet extends StatelessWidget {
  final VoidCallback? onManualAdd;
  final VoidCallback? onCsvImport;

  const AddProductOptionsSheet({
    super.key,
    this.onManualAdd,
    this.onCsvImport,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onManualAdd,
    VoidCallback? onCsvImport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductOptionsSheet(
        onManualAdd: onManualAdd,
        onCsvImport: onCsvImport,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Section header
          BrutalSectionHeader(
            title: 'Tambah Produk',
            icon: Icons.add_circle_outline,
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          // Manual add option
          BrutalCard(
            onTap: onManualAdd,
            padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.primary,
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: NeoBrutalTheme.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Produk Manual',
                        style: NeoBrutalTheme.headlineSmall,
                      ),
                      Text(
                        'Masukkan produk satu per satu',
                        style: NeoBrutalTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          // CSV import option
          BrutalCard(
            onTap: onCsvImport,
            padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.secondary,
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: NeoBrutalTheme.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import dari CSV',
                        style: NeoBrutalTheme.headlineSmall,
                      ),
                      Text(
                        'Import banyak produk sekaligus',
                        style: NeoBrutalTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
