import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/shift_controller.dart';
import 'shift_open_screen.dart';
import 'shift_close_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_button.dart';

/// Screen for managing cashier shifts
class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftController>().loadCurrentShift();
      context.read<ShiftController>().loadShiftHistory();
    });
  }

  Future<void> _handleOpenShift() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ShiftOpenScreen()),
    );
    if (result == true && mounted) {
      context.read<ShiftController>().loadCurrentShift();
      context.read<ShiftController>().loadShiftHistory();
    }
  }

  Future<void> _handleCloseShift() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ShiftCloseScreen(),
      ),
    );
    if (result == true && mounted) {
      context.read<ShiftController>().loadCurrentShift();
      context.read<ShiftController>().loadShiftHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Manajemen Shift'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ShiftController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.shiftHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadCurrentShift();
              await controller.loadShiftHistory();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current Shift Section
                _buildCurrentShiftSection(context, controller),

                const SizedBox(height: 20),

                // Shift History Section
                _buildShiftHistorySection(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentShiftSection(BuildContext context, ShiftController controller) {
    final hasActiveShift = controller.hasActiveShift;
    final currentShift = controller.currentShift;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasActiveShift
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasActiveShift ? Icons.store : Icons.store_outlined,
                  color: hasActiveShift ? AppTheme.successColor : AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shift Saat Ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasActiveShift ? 'Sedang Aktif' : 'Tidak Aktif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hasActiveShift ? AppTheme.successColor : AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasActiveShift)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'BUKA',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
            ],
          ),

          if (hasActiveShift && currentShift != null) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildShiftDetailRow(
              context,
              icon: Icons.person,
              label: 'Kasir',
              value: currentShift.userName,
            ),
            const SizedBox(height: 12),
            _buildShiftDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Dibuka',
              value: _formatDateTime(currentShift.openedAt),
            ),
            const SizedBox(height: 12),
            _buildShiftDetailRow(
              context,
              icon: Icons.payments_outlined,
              label: 'Modal Awal',
              value: _formatCurrency(currentShift.openingBalance),
              valueColor: AppTheme.infoColor,
            ),
            const SizedBox(height: 12),
            _buildShiftDetailRow(
              context,
              icon: Icons.shopping_cart_outlined,
              label: 'Transaksi',
              value: '${currentShift.totalTransactions}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSalesCard(
                    context,
                    label: 'Tunai',
                    amount: currentShift.cashSales,
                    icon: Icons.money,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSalesCard(
                    context,
                    label: 'Kartu',
                    amount: currentShift.cardSales,
                    icon: Icons.credit_card,
                    color: AppTheme.infoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSalesCard(
                    context,
                    label: 'QRIS',
                    amount: currentShift.qrSales,
                    icon: Icons.qr_code,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSalesCard(
                    context,
                    label: 'Transfer',
                    amount: currentShift.transferSales,
                    icon: Icons.account_balance,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: hasActiveShift ? 'Tutup Shift' : 'Buka Shift Baru',
              icon: hasActiveShift ? Icons.close : Icons.play_arrow,
              onPressed: hasActiveShift ? _handleCloseShift : _handleOpenShift,
              backgroundColor: hasActiveShift ? AppTheme.errorColor : AppTheme.successColor,
              isLoading: controller.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftHistorySection(BuildContext context, ShiftController controller) {
    final history = controller.shiftHistory;

    if (history.isEmpty) {
      return ModernCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Riwayat Shift',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shift yang sudah ditutup akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Shift',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 16),
        ...history.map((shift) => _buildShiftHistoryCard(context, shift)),
      ],
    );
  }

  Widget _buildShiftHistoryCard(BuildContext context, shift) {
    final isClosed = shift.closedAt != null;
    final totalSales = shift.cashSales + shift.cardSales + shift.qrSales + shift.transferSales;

    return ModernCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    Text(
                      _formatDateTime(shift.openedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isClosed
                      ? AppTheme.successColor.withValues(alpha: 0.15)
                      : AppTheme.warningColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isClosed
                        ? AppTheme.successColor.withValues(alpha: 0.3)
                        : AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isClosed ? 'DITUTUP' : 'AKTIF',
                  style: TextStyle(
                    color: isClosed ? AppTheme.successColor : AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
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
                  label: 'Modal',
                  value: _formatCurrency(shift.openingBalance),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Penjualan',
                  value: _formatCurrency(totalSales),
                  icon: Icons.point_of_sale,
                  color: AppTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Transaksi',
                  value: '${shift.totalTransactions}',
                  icon: Icons.receipt_long,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          if (isClosed) ...[
            const SizedBox(height: 12),
            _buildShiftDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Durasi',
              value: _calculateDuration(shift.openedAt, shift.closedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.getTextSecondaryColor(context)),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesCard(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? AppTheme.getTextSecondaryColor(context)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.getTextPrimaryColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
  }

  String _calculateDuration(int openedAt, int closedAt) {
    final difference = closedAt - openedAt;
    final hours = difference ~/ 3600;
    final minutes = (difference % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
  }
}
