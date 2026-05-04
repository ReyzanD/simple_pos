import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/modern_card.dart';
import 'package:simple_pos/l10n/app_localizations.dart';
import '../../domain/usecases/get_held_carts_usecase.dart';
import '../../../shared/presentation/providers.dart';

/// Screen displaying all held orders
class HeldOrdersScreen extends ConsumerStatefulWidget {
  const HeldOrdersScreen({super.key});

  @override
  ConsumerState<HeldOrdersScreen> createState() => _HeldOrdersScreenState();
}

class _HeldOrdersScreenState extends ConsumerState<HeldOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Load held carts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(posControllerProvider).loadHeldCarts();
    });
  }

  Future<void> _handleResumeOrder(int heldCartId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.held_order_continue),
        content: Text(AppLocalizations.of(context)!.held_order_current_cart),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.held_order_continue),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(posControllerProvider)
          .resumeCart(heldCartId);
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.held_order_continue),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final controller = ref.read(posControllerProvider);
          if (controller.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.error!.userMessage),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _handleDeleteOrder(int heldCartId, String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.held_order_delete),
        content: Text(
          AppLocalizations.of(
            context,
          )!.held_order_delete_confirm.replaceAll('{name}', customerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(AppLocalizations.of(context)!.held_order_delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(posControllerProvider)
          .deleteHeldCart(heldCartId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.held_order_delete),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final controller = ref.read(posControllerProvider);
          if (controller.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.error!.userMessage),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(posControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.held_orders_title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: () {
        if (controller.isLoadingHeldCarts) {
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
                  controller.error!.userMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.loadHeldCarts(),
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.common_retry),
                ),
              ],
            ),
          );
        }

        if (controller.heldCarts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.held_order_no_orders,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.held_order_hold,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadHeldCarts(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.heldCarts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final heldCart = controller.heldCarts[index];
              return _buildHeldOrderCard(heldCart);
            },
          ),
        );
      }(),
    );
  }

  Widget _buildHeldOrderCard(HeldCart heldCart) {
    return ModernCard(
      child: InkWell(
        onTap: () => _handleResumeOrder(heldCart.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.pause_circle, color: AppTheme.infoColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heldCart.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          heldCart.formattedTime,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.shopping_bag_outlined,
                      '${heldCart.itemCount} Item',
                      AppTheme.primaryColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppTheme.dividerColor),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.payments_outlined,
                      CurrencyFormatter.format(heldCart.totalAmount),
                      AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDeleteOrder(
                        heldCart.id,
                        heldCart.customerName,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        AppLocalizations.of(context)!.held_order_delete,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(
                          color: AppTheme.errorColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleResumeOrder(heldCart.id),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(
                        AppLocalizations.of(context)!.held_order_continue,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
