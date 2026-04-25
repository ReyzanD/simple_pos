import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/discount_preset.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/theme.dart';
import 'add_preset_dialog.dart';

/// Discount Presets Tab Widget - manages reusable discount templates
class DiscountPresetsTabWidget extends ConsumerWidget {
  const DiscountPresetsTabWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(discountControllerProvider);
    final content = _buildContent(controller);

    // Wrap in Scaffold with FAB
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'discount_presets_fab', // ✅ Unique hero tag
        onPressed: controller.isLoading
            ? null
            : () => _showAddDialog(context, controller),
        backgroundColor: AppTheme.infoColor,
        icon: const Icon(Icons.add),
        label: const Text('Buat Preset'),
      ),
      body: content,
    );
  }

  Widget _buildContent(dynamic controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              controller.error?.userMessage ?? 'Terjadi kesalahan',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadDiscountPresets(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (controller.discountPresets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Belum ada preset diskon',
              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan + untuk membuat preset diskon baru',
              style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.discountPresets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final preset = controller.discountPresets[index];
        return _buildPresetCard(context, preset, controller);
      },
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    DiscountPreset preset,
    dynamic controller,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showPresetDetails(context, preset, controller),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Discount icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${preset.discountPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Preset details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (preset.description.isNotEmpty)
                      Text(
                        preset.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                onPressed: () => _confirmDelete(context, preset, controller),
                tooltip: 'Hapus',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetDetails(
    BuildContext context,
    DiscountPreset preset,
    dynamic controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddPresetDialog(
        preset: preset,
        onAdd: ({
          required name,
          required description,
          required discountPercentage,
        }) async => false, // Not used in edit mode
        onUpdate: controller.updateDiscountPreset,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DiscountPreset preset,
    dynamic controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Preset Diskon'),
        content: Text('Apakah Anda yakin ingin menghapus "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteDiscountPreset(preset.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, dynamic controller) {
    showDialog(
      context: context,
      builder: (context) => AddPresetDialog(
        onAdd: controller.addDiscountPreset,
      ),
    );
  }
}
