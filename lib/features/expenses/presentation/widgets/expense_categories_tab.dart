import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/contextual_error_display.dart';
import '../../../expenses/domain/constants/expense_categories.dart';
import '../../../expenses/presentation/utils/expense_category_helper.dart';
import '../controllers/expense_controller.dart';

class ExpenseCategoriesTab extends StatefulWidget {
  final ExpenseController controller;

  const ExpenseCategoriesTab({required this.controller, super.key});

  @override
  State<ExpenseCategoriesTab> createState() => _ExpenseCategoriesTabState();
}

class _ExpenseCategoriesTabState extends State<ExpenseCategoriesTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadCategoryCounts();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      );
    }

    if (controller.hasError) {
      return ContextualErrorDisplay.auto(
        error: controller.error!,
        onRetry: controller.loadCategoryCounts,
      );
    }

    final categories = ExpenseCategories.predefined;
    final counts = controller.categoryCounts;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Kategori Pengeluaran',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...categories.map((cat) {
          final count = counts[cat] ?? 0;
          return _CategoryCard(
            categoryName: cat,
            expenseCount: count,
          );
        }),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final int expenseCount;

  const _CategoryCard({
    required this.categoryName,
    required this.expenseCount,
  });

  Color _getCategoryColor(String category) {
    return ExpenseCategoryHelper.getCategoryColor(category);
  }

  IconData _getCategoryIcon(String category) {
    return ExpenseCategoryHelper.getCategoryIcon(category);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(categoryName).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(categoryName),
              color: _getCategoryColor(categoryName),
            ),
          ),
          const SizedBox(width: 16),
          // Name and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$expenseCount pengeluaran',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
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
