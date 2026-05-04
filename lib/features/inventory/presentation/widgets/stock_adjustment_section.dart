import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class StockAdjustmentSection extends StatefulWidget {
  final StockAdjustmentType selectedType;
  final int? adjustmentQuantity;
  final ValueChanged<StockAdjustmentType?>? onTypeChanged;
  final ValueChanged<int?>? onQuantityChanged;
  final Future<void> Function()? onAdd;
  final Future<void> Function()? onRemove;
  final Future<void> Function()? onSet;

  const StockAdjustmentSection({
    super.key,
    required this.selectedType,
    this.adjustmentQuantity,
    this.onTypeChanged,
    this.onQuantityChanged,
    this.onAdd,
    this.onRemove,
    this.onSet,
  });

  @override
  State<StockAdjustmentSection> createState() => _StockAdjustmentSectionState();
}

class _StockAdjustmentSectionState extends State<StockAdjustmentSection> {
  late TextEditingController _quantityController;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.adjustmentQuantity?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(StockAdjustmentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adjustmentQuantity != oldWidget.adjustmentQuantity) {
      final newText = widget.adjustmentQuantity?.toString() ?? '';
      if (_quantityController.text != newText) {
        _quantityController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String _getTypeLabel(StockAdjustmentType type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case StockAdjustmentType.set:
        return l10n.stock_setStock;
      case StockAdjustmentType.purchase:
        return l10n.stock_purchase;
      case StockAdjustmentType.sale:
        return l10n.stock_sale;
      case StockAdjustmentType.damage:
        return l10n.stock_damage;
      case StockAdjustmentType.itemReturn:
        return l10n.stock_itemReturn;
      case StockAdjustmentType.manual:
        return l10n.stock_manual;
      case StockAdjustmentType.other:
        return l10n.stock_other;
    }
  }

  IconData _getTypeIcon(StockAdjustmentType type) {
    switch (type) {
      case StockAdjustmentType.set:
        return Icons.check_circle;
      case StockAdjustmentType.purchase:
        return Icons.shopping_cart;
      case StockAdjustmentType.sale:
        return Icons.sell;
      case StockAdjustmentType.damage:
        return Icons.warning;
      case StockAdjustmentType.itemReturn:
        return Icons.undo;
      case StockAdjustmentType.manual:
        return Icons.build;
      case StockAdjustmentType.other:
        return Icons.more_horiz;
    }
  }

  bool get _isQuantityValid {
    if (_quantityController.text.isEmpty) return false;
    final quantity = int.tryParse(_quantityController.text);
    return quantity != null && quantity > 0;
  }

  String? _validateQuantity(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_quantityController.text.isEmpty) return null;
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null) return l10n.stock_invalidNumber;
    if (quantity <= 0) return l10n.stock_quantityMin;
    if (quantity > 999999) return l10n.stock_quantityMax;
    return null;
  }

  Future<void> _handleAction() async {
    if (!_isQuantityValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      switch (widget.selectedType) {
        case StockAdjustmentType.set:
          await widget.onSet?.call();
          break;
        case StockAdjustmentType.damage:
        case StockAdjustmentType.sale:
          final confirmed = await _showConfirmationDialog();
          if (confirmed) await widget.onRemove?.call();
          break;
        default:
          await widget.onAdd?.call();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.stock_confirmAction),
            content: Text(
              AppLocalizations.of(
                context,
              )!.stock_removeQuantity(_quantityController.text),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.stock_cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: Text(AppLocalizations.of(context)!.stock_confirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isSetType = widget.selectedType == StockAdjustmentType.set;
    final isRemovalType =
        widget.selectedType == StockAdjustmentType.damage ||
        widget.selectedType == StockAdjustmentType.sale;

    return Semantics(
      label: 'Bagian penyesuaian stok',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.stock_adjustmentTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StockAdjustmentType>(
              initialValue: widget.selectedType,
              onChanged: widget.onTypeChanged,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.stock_adjustmentType,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF4F46E5),
                    width: 2,
                  ),
                ),
              ),
              dropdownColor: Colors.white,
              isExpanded: true,
              items: StockAdjustmentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 18,
                        color: const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getTypeLabel(type, context),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.stock_quantity,
                hintText: AppLocalizations.of(context)!.stock_quantityHint,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.inventory_2, size: 20),
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF4F46E5),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  _errorText = _validateQuantity(context);
                  final int? quantity = int.tryParse(value);
                  widget.onQuantityChanged?.call(quantity);
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isQuantityValid && !_isLoading
                    ? _handleAction
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        isSetType
                            ? Icons.settings
                            : isRemovalType
                            ? Icons.remove
                            : Icons.add,
                        size: 20,
                      ),
                label: Text(
                  _isLoading
                      ? AppLocalizations.of(context)!.stock_processing
                      : isSetType
                      ? AppLocalizations.of(context)!.stock_setStockAction
                      : isRemovalType
                      ? AppLocalizations.of(context)!.stock_removeStock
                      : AppLocalizations.of(context)!.stock_addStock,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSetType
                      ? const Color(0xFF14B8A6)
                      : isRemovalType
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
