import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/promotion.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/theme.dart';
import 'add_promotion_dialog.dart';

/// Promotions Tab Widget - manages time-limited discount campaigns
class PromotionsTabWidget extends ConsumerWidget {
  const PromotionsTabWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(discountControllerProvider);
    final content = _buildContent(controller);

    // Wrap in Scaffold with FAB
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'promotions_fab', // ✅ Unique hero tag
        onPressed: controller.isLoading
            ? null
            : () => _showAddDialog(context, controller),
        backgroundColor: AppTheme.warningColor,
        icon: const Icon(Icons.add),
        label: const Text('Buat Promosi'),
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
              onPressed: () => controller.loadPromotions(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (controller.promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Belum ada promosi',
              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan + untuk membuat promosi baru',
              style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Active promotions summary
        if (controller.activePromotions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.successColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${controller.activePromotions.length} promosi aktif',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Promotions list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.promotions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final promotion = controller.promotions[index];
              return _buildPromotionCard(context, promotion, controller);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(
    BuildContext context,
    Promotion promotion,
    dynamic controller,
  ) {
    final isActive = promotion.isActive;
    final isScheduled = promotion.isScheduled;
    final isExpired = promotion.isExpired;

    return Card(
      elevation: isActive ? 2 : 1,
      child: InkWell(
        onTap: () => _showPromotionDetails(context, promotion, controller),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: AppTheme.successColor.withValues(alpha: 0.3), width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      promotion.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusBadge(isActive, isScheduled, isExpired),
                ],
              ),

              const SizedBox(height: 8),

              // Discount percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${promotion.discountPercentage.toStringAsFixed(0)}% OFF',
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Description
              if (promotion.description.isNotEmpty)
                Text(
                  promotion.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

              const SizedBox(height: 12),

              // Date range
              if (promotion.hasDateRange) ...[
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDateRange(promotion.startDate, promotion.endDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  // Toggle button
                  Switch(
                    value: promotion.isEnabled,
                    onChanged: (value) {
                      controller.togglePromotion(promotion.id!, value);
                    },
                    activeThumbColor: AppTheme.successColor,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    promotion.isEnabled ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontSize: 14,
                      color: promotion.isEnabled ? AppTheme.successColor : AppTheme.textTertiary,
                    ),
                  ),

                  const Spacer(),

                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                    onPressed: () => _confirmDelete(context, promotion, controller),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isScheduled, bool isExpired) {
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Kedaluwarsa',
          style: TextStyle(
            color: AppTheme.errorColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (isScheduled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.infoColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Terjadwal',
          style: TextStyle(
            color: AppTheme.infoColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Aktif',
          style: TextStyle(
            color: AppTheme.successColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Nonaktif',
        style: TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Mulai: ${_formatDate(start)}';
    } else if (end != null) {
      return 'Selesai: ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPromotionDetails(
    BuildContext context,
    Promotion promotion,
    dynamic controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddPromotionDialog(
        promotion: promotion,
        onAdd: ({
          required name,
          required description,
          required discountPercentage,
          startDate,
          endDate,
          isEnabled = true,
        }) async => false, // Not used in edit mode
        onUpdate: controller.updatePromotion,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Promotion promotion,
    dynamic controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Promosi'),
        content: Text('Apakah Anda yakin ingin menghapus "${promotion.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deletePromotion(promotion.id!);
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
      builder: (context) => AddPromotionDialog(
        onAdd: controller.addPromotion,
      ),
    );
  }
}
