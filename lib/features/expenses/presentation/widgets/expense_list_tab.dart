import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_empty_state.dart';
import '../../../../core/widgets/contextual_error_display.dart';
import '../controllers/expense_controller.dart';
import '../../domain/entities/expense.dart';
import 'expense_filter_bar.dart';
import 'expense_card.dart';
import 'expense_form_dialog.dart';

class ExpenseListTab extends StatefulWidget {
  final ExpenseController controller;

  const ExpenseListTab({required this.controller, super.key});

  @override
  State<ExpenseListTab> createState() => _ExpenseListTabState();
}

class _ExpenseListTabState extends State<ExpenseListTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadExpenses();
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

    return Column(
      children: [
        ExpenseFilterBar(
          selectedCategory: controller.selectedCategory,
          dateRange: controller.startDate != null && controller.endDate != null
              ? DateTimeRange(
                  start: controller.startDate!,
                  end: controller.endDate!,
                )
              : null,
          onCategoryChanged: (cat) {
            controller.setCategoryFilter(cat);
          },
          onDateRangeChanged: (range) {
            if (range != null) {
              controller.setDateRangeFilter(range.start, range.end);
            } else {
              controller.setDateRangeFilter(null, null);
            }
          },
          onClearFilters: controller.clearFilters,
        ),
        Expanded(child: _buildContent(controller)),
      ],
    );
  }

  Widget _buildContent(ExpenseController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      );
    }

    if (controller.hasError) {
      return ContextualErrorDisplay.auto(
        error: controller.error!,
        onRetry: controller.loadExpenses,
      );
    }

    final expenses = controller.expenses;

    if (expenses.isEmpty) {
      return AnimatedEmptyState.noExpenses(
        context: context,
        onAction: () => _showAddDialog(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ExpenseCard(
            expense: expenses[index],
            onEdit: () => _showEditDialog(context, expenses[index]),
            onDelete: () => controller.deleteExpense(expenses[index].id!),
            onViewReceipt: expenses[index].receiptImagePath != null
                ? () => _showReceiptImage(
                    context,
                    expenses[index].receiptImagePath!,
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) async {
    await showExpenseFormDialog(context);
  }

  void _showEditDialog(BuildContext context, Expense expense) async {
    await showExpenseFormDialog(context, expense: expense);
  }

  void _showReceiptImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bukti Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Image
              Expanded(
                child: InteractiveViewer(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat gambar',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
