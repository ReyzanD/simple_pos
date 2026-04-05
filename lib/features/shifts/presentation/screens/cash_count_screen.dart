import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/shift_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/bill_counter_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../domain/entities/cash_denomination.dart';

/// Screen for counting cash by denomination at shift close
class CashCountScreen extends StatefulWidget {
  final int shiftId;
  final double expectedAmount;

  const CashCountScreen({
    super.key,
    required this.shiftId,
    required this.expectedAmount,
  });

  @override
  State<CashCountScreen> createState() => _CashCountScreenState();
}

class _CashCountScreenState extends State<CashCountScreen> {
  final Map<int, int> _billCounts = {};
  int _selectedDenomination = 0;
  bool _isSaving = false;

  int get _totalCounted {
    return _billCounts.entries
        .fold<int>(0, (sum, entry) => sum + (entry.key * entry.value));
  }

  int get _discrepancy => _totalCounted - widget.expectedAmount.toInt();

  @override
  Widget build(BuildContext context) {
    final isPositive = _discrepancy >= 0;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Hitung Uang di Laci'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ShiftController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              // Expected amount display
              ModernCard(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Diharapkan:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    Text(
                      'Rp ${_formatCurrency(widget.expectedAmount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Denomination grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(8),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: CashDenomination.all.map((denom) {
                    final count = _billCounts[denom.value] ?? 0;
                    return BillCounterButton(
                      denomination: denom,
                      count: count,
                      isSelected: _selectedDenomination == denom.value,
                      onTap: () {
                        setState(() {
                          _selectedDenomination = denom.value;
                        });
                      },
                      onIncrement: () {
                        setState(() {
                          _billCounts[denom.value] = count + 1;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              // Summary card
              ModernCard(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Dihitung:',
                      'Rp ${_formatCurrency(_totalCounted.toDouble())}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Diharapkan:',
                      'Rp ${_formatCurrency(widget.expectedAmount)}',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: AppTheme.getBorderColor(context),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Selisih:',
                      'Rp ${_formatCurrency(_discrepancy.abs().toDouble())}',
                      color: isPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Batal',
                        onPressed: () => Navigator.pop(context, false),
                        backgroundColor: AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernButton(
                        text: 'Simpan & Tutup',
                        onPressed: _isSaving ? null : _handleSave,
                        isLoading: _isSaving,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    // TODO: Save via use case - will be wired in next phase
    // For now, just return success
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(context, true);
    }

    setState(() => _isSaving = false);
  }

  String _formatCurrency(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
