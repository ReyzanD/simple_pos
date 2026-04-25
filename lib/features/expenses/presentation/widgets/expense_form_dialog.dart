import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/widgets/validated_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/services/success_toast_service.dart';
import '../../domain/constants/expense_categories.dart';
import '../../domain/entities/expense_payment_method.dart';
import '../../domain/entities/expense.dart';
import '../../../shared/presentation/providers.dart';
import '../utils/expense_category_helper.dart';

/// Dialog for adding or editing expenses with receipt image support
class ExpenseFormDialog extends ConsumerWidget {
  final Expense? expense; // If provided, edit mode; otherwise add mode

  const ExpenseFormDialog({
    super.key,
    this.expense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ExpenseFormDialogContent(
      expense: expense,
      controller: ref.watch(expenseControllerProvider),
    );
  }
}

class _ExpenseFormDialogContent extends StatefulWidget {
  final Expense? expense;
  final dynamic controller;

  const _ExpenseFormDialogContent({
    super.key,
    required this.expense,
    required this.controller,
  });

  @override
  State<_ExpenseFormDialogContent> createState() => _ExpenseFormDialogContentState();
}

class _ExpenseFormDialogContentState extends State<_ExpenseFormDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = ExpenseCategories.predefined.first;
  ExpensePaymentMethod _selectedPaymentMethod = ExpensePaymentMethod.cash;
  String? _receiptImagePath;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _initializeFromExpense(widget.expense!);
    }
  }

  void _initializeFromExpense(Expense expense) {
    _selectedCategory = expense.category;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description ?? '';
    _selectedPaymentMethod = expense.paymentMethod;
    _receiptImagePath = expense.receiptImagePath;
    _selectedDate = expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.expense != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          border: Border.all(
            color: Colors.black,
            width: 5, // ✅ Extra bold border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Category selector
                      _buildCategorySelector(context),

                      const SizedBox(height: 16),

                      // Amount input
                      _buildAmountInput(context),

                      const SizedBox(height: 16),

                      // Description input
                      _buildDescriptionInput(context),

                      const SizedBox(height: 16),

                      // Payment method selector
                      _buildPaymentMethodSelector(context),

                      const SizedBox(height: 16),

                      // Date selector
                      _buildDateSelector(context),

                      const SizedBox(height: 16),

                      // Receipt image picker
                      _buildReceiptImagePicker(context),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with buttons
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isEditMode ? Icons.edit_outlined : Icons.receipt_long_outlined,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Pengeluaran' : 'Tambah Pengeluaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                Text(
                  _isEditMode
                      ? 'Ubah detail pengeluaran'
                      : 'Catat pengeluaran operasional',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: AppTheme.getCardColor(context),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              items: ExpenseCategories.predefined.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ExpenseCategoryHelper.getCategoryColor(category)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          ExpenseCategoryHelper.getCategoryIcon(category),
                          color: ExpenseCategoryHelper.getCategoryColor(category),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    return ValidatedTextField(
      label: 'Jumlah',
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.payments_outlined,
      helperText: 'Rp 0',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Jumlah wajib diisi';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Masukkan jumlah yang valid';
        }
        return null;
      },
      debounceMs: 0,
    );
  }

  Widget _buildDescriptionInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi (opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Catatan tambahan',
            prefixIcon: const Icon(Icons.description_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ExpensePaymentMethod.values.map((method) {
            final isSelected = _selectedPaymentMethod == method;
            final color = _getPaymentMethodColor(method);

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getPaymentMethodIcon(method), size: 16, color: isSelected ? color : null),
                  const SizedBox(width: 6),
                  Text(_getPaymentMethodDisplayName(method)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPaymentMethod = method);
                }
              },
              selectedColor: color.withValues(alpha: 0.15),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? color : AppTheme.borderColor,
                ),
              ),
              backgroundColor: Colors.transparent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptImagePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bukti Pembayaran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (_receiptImagePath != null)
              TextButton.icon(
                onPressed: () => setState(() => _receiptImagePath = null),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickReceiptImage(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _receiptImagePath != null
                    ? AppTheme.successColor.withValues(alpha: 0.5)
                    : AppTheme.getBorderColor(context),
                width: _receiptImagePath != null ? 2 : 1,
              ),
            ),
            child: _receiptImagePath != null
                ? _buildReceiptPreview()
                : _buildReceiptPlaceholder(context),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptPreview() {
    final file = File(_receiptImagePath!);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.file(
              file,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return _buildReceiptPlaceholder(context);
  }

  Widget _buildReceiptPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: AppTheme.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap untuk ambil foto',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          'Kamera atau Galeri',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppTheme.getBorderColor(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModernButton(
              text: _isEditMode ? 'Simpan' : 'Tambah',
              icon: _isEditMode ? Icons.save : Icons.add,
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickReceiptImage(BuildContext context) async {
    final picker = ImagePicker();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImageSourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Kamera',
                    onTap: () async {
                      Navigator.of(context).pop();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                        maxWidth: 1200,
                        maxHeight: 1200,
                      );
                      if (image != null && mounted) {
                        setState(() => _receiptImagePath = image.path);
                      }
                    },
                  ),
                  _ImageSourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeri',
                    onTap: () async {
                      Navigator.of(context).pop();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxWidth: 1200,
                        maxHeight: 1200,
                      );
                      if (image != null && mounted) {
                        setState(() => _receiptImagePath = image.path);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Validate amount
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() {
        // Show error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = widget.controller;

      final success = _isEditMode
          ? await controller.updateExpense(
                Expense(
                  id: widget.expense!.id,
                  category: _selectedCategory,
                  amount: amount,
                  description: _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
                  paymentMethod: _selectedPaymentMethod,
                  receiptImagePath: _receiptImagePath,
                  date: _selectedDate,
                  createdAt: widget.expense!.createdAt,
                ),
              )
          : await controller.addExpense(
              category: _selectedCategory,
              amount: amount,
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              paymentMethod: _selectedPaymentMethod,
              receiptImagePath: _receiptImagePath,
            );

      if (mounted) {
        if (success) {
          SuccessToastService.instance.added(context, 'Pengeluaran');
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _isEditMode ? 'Gagal memperbarui pengeluaran' : 'Gagal menambah pengeluaran'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getPaymentMethodColor(ExpensePaymentMethod method) {
    switch (method) {
      case ExpensePaymentMethod.cash:
        return AppTheme.successColor;
      case ExpensePaymentMethod.transfer:
        return AppTheme.infoColor;
      case ExpensePaymentMethod.card:
        return AppTheme.warningColor;
      case ExpensePaymentMethod.other:
        return AppTheme.primaryColor;
    }
  }

  IconData _getPaymentMethodIcon(ExpensePaymentMethod method) {
    switch (method) {
      case ExpensePaymentMethod.cash:
        return Icons.money;
      case ExpensePaymentMethod.transfer:
        return Icons.account_balance;
      case ExpensePaymentMethod.card:
        return Icons.credit_card;
      case ExpensePaymentMethod.other:
        return Icons.payment;
    }
  }

  String _getPaymentMethodDisplayName(ExpensePaymentMethod method) {
    switch (method) {
      case ExpensePaymentMethod.cash:
        return 'Tunai';
      case ExpensePaymentMethod.transfer:
        return 'Transfer';
      case ExpensePaymentMethod.card:
        return 'Kartu';
      case ExpensePaymentMethod.other:
        return 'Lainnya';
    }
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show expense form dialog and return true if expense was added/updated
Future<bool> showExpenseFormDialog(BuildContext context, {Expense? expense}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ExpenseFormDialog(expense: expense),
  );
  return result ?? false;
}
