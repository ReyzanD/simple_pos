import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_payment_method.dart';
import '../utils/expense_category_helper.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewReceipt;

  const ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    this.onViewReceipt,
    super.key,
  });

  String _getPaymentMethodLabel(ExpensePaymentMethod method) {
    return switch (method) {
      ExpensePaymentMethod.cash => 'Tunai',
      ExpensePaymentMethod.transfer => 'Transfer',
      ExpensePaymentMethod.card => 'Kartu',
      ExpensePaymentMethod.other => 'Lainnya',
    };
  }

  Color _getCategoryColor(String category) {
    return ExpenseCategoryHelper.getCategoryColor(category);
  }

  IconData _getCategoryIcon(String category) {
    return ExpenseCategoryHelper.getCategoryIcon(category);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          side: BorderSide(
            color: Colors.black,
            width: 4,
          ),
        ),
        title: Text(
          'Hapus Pengeluaran',
          style: NeoBrutalTheme.headlineSmall.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus pengeluaran ini?',
          style: NeoBrutalTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getTextSecondaryColor(context),
              textStyle: NeoBrutalTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              textStyle: NeoBrutalTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppTheme.infoColor,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(context),
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          border: Border.all(
            color: Colors.black,
            width: 3, // ✅ Bold border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Category indicator with brutal styling
            Container(
              width: 6,
              height: 56,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(expense.category).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                          border: Border.all(
                            color: _getCategoryColor(expense.category),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getCategoryIcon(expense.category),
                          size: 14,
                          color: _getCategoryColor(expense.category),
                        ),
                      ),
                      SizedBox(width: NeoBrutalTheme.spaceXS),
                      Text(
                        expense.category.toUpperCase(),
                        style: NeoBrutalTheme.labelSmall.copyWith(
                          color: _getCategoryColor(expense.category),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceXS),
                  Text(
                    expense.description ?? '-',
                    style: NeoBrutalTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceXS),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(expense.amount),
                        style: NeoBrutalTheme.headlineSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: NeoBrutalTheme.spaceMD),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: NeoBrutalTheme.spaceSM,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getPaymentMethodLabel(expense.paymentMethod),
                          style: NeoBrutalTheme.labelSmall.copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: NeoBrutalTheme.spaceSM),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: NeoBrutalTheme.labelSmall.copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Receipt indicator
            if (expense.receiptImagePath != null) ...[
              SizedBox(width: NeoBrutalTheme.spaceMD),
              GestureDetector(
                onTap: onViewReceipt,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.infoColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppTheme.infoColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
