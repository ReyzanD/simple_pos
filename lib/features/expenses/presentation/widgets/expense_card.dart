import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
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
        title: const Text('Hapus Pengeluaran'),
        content: const Text('Yakin ingin menghapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
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
      child: ModernCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category indicator
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(expense.category),
                        size: 16,
                        color: _getCategoryColor(expense.category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expense.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(expense.category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.description ?? '-',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(expense.amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getPaymentMethodLabel(expense.paymentMethod),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Receipt indicator
            if (expense.receiptImagePath != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onViewReceipt,
                child: Icon(Icons.receipt_long, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
