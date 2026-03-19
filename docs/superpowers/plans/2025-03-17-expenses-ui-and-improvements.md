# Expenses UI and UI Improvements Implementation Plan

> **Note on State Management**: Use `Consumer<ExpenseController>` instead of `ListenableBuilder` for consistency with existing codebase. Replace all `ListenableBuilder(listenable: widget.controller, ...)` with `Consumer<ExpenseController>(builder: (context, controller, ...)`.

> **Note on Expense Entity**: The actual `Expense` entity uses `receiptImagePath` (not `receiptImage`). Update references accordingly. Also `ExpenseCategories` uses `predefined` list (not `.all`), access via `ExpenseCategories.predefined`.

**Architecture:** Flutter Clean Architecture with Provider state management. UI improvements are reusable core widgets; Expenses feature uses these widgets following existing domain/data/presentation patterns.

**Tech Stack:** Flutter 3.x, Provider, fl_chart, flutter_slidable, image_picker, path_provider

---

## Implementation Order

**Phase 1: UI Improvements Foundation** (Tasks 1-6)
- Build reusable widgets first: empty states, error display, form validation, search state, success toasts, loading overlay
- These are used by the Expenses feature

**Phase 2: Expenses Domain Layer** (Tasks 7-8, 10)
- Profit report entity (Task 7)
- Category count use case (Task 8)
- Profit report use case (Task 10)

**Phase 3: Expenses Controller Extension** (Task 9)
- Must be completed before widgets (Tasks 12-17)

**Phase 4: Expenses Presentation Utilities** (Task 11)
- Category helper

**Phase 5: Expenses Presentation Widgets** (Tasks 12-17)
- Filter bar, card, list tab, summary tab, categories tab, main screen

**Phase 6: Navigation** (Task 18)
- Drawer navigation

**Phase 7: DI Configuration** (Task 19)
- Dependency injection chain setup

**Phase 8: Integration** (Task 20)
- Sales report profit integration

**Phase 9: Expense Form Dialog** (Task 21) - CRITICAL COMPONENT
- Add/edit expense dialog with receipt handling

---

## Task 1: Enhanced Empty States

**Files:**
- Modify: `lib/core/widgets/animated_empty_state.dart`

- [ ] **Step 1: Read existing AnimatedEmptyState widget**

```bash
# Read the current implementation to understand the constructor parameters
```

Expected: Widget has `icon`, `title`, `subtitle`, `actionText`, `onAction` parameters

- [ ] **Step 2: Add 7 factory methods to AnimatedEmptyState class**

Add these factory methods after the existing constructor:

```dart
// Preset factory methods
factory AnimatedEmptyState.noProducts({VoidCallback? onAction}) =>
    AnimatedEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Belum Ada Produk',
      subtitle: 'Mulai tambahkan produk ke inventaris Anda',
      actionText: 'Tambah Produk',
      onAction: onAction,
    );

factory AnimatedEmptyState.noTransactions({VoidCallback? onAction}) =>
    AnimatedEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Belum Ada Transaksi',
      subtitle: 'Transaksi penjualan Anda akan muncul di sini',
      actionText: 'Mulai Transaksi',
      onAction: onAction,
    );

factory AnimatedEmptyState.noExpenses({VoidCallback? onAction}) =>
    AnimatedEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Belum Ada Pengeluaran',
      subtitle: 'Catat pengeluaran operasional toko',
      actionText: 'Tambah Pengeluaran',
      onAction: onAction,
    );

factory AnimatedEmptyState.noSuppliers({VoidCallback? onAction}) =>
    AnimatedEmptyState(
      icon: Icons.local_shipping_outlined,
      title: 'Belum Ada Pemasok',
      subtitle: 'Tambahkan pemasok untuk inventori Anda',
      actionText: 'Tambah Pemasok',
      onAction: onAction,
    );

factory AnimatedEmptyState.noCategories({VoidCallback? onAction}) =>
    AnimatedEmptyState(
      icon: Icons.category_outlined,
      title: 'Belum Ada Kategori',
      subtitle: 'Kategori membantu mengelola produk',
      actionText: 'Tambah Kategori',
      onAction: onAction,
    );

factory AnimatedEmptyState.searchNoResults({String? query}) =>
    AnimatedEmptyState(
      icon: Icons.search_off_rounded,
      title: 'Tidak Ditemukan',
      subtitle: query != null ? 'Tidak ada hasil untuk "$query"' : 'Coba kata kunci lain',
    );

factory AnimatedEmptyState.noNetwork({VoidCallback? onRetry}) =>
    AnimatedEmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Tidak Ada Koneksi',
      subtitle: 'Periksa koneksi internet Anda',
      actionText: 'Coba Lagi',
      onAction: onRetry,
    );
```

- [ ] **Step 3: Test factory methods work**

```bash
flutter run
# Navigate to a screen with empty state, verify it displays correctly
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/widgets/animated_empty_state.dart
git commit -m "feat(core): add empty state factory methods (noProducts, noTransactions, noExpenses, noSuppliers, noCategories, searchNoResults, noNetwork)"
```

---

## Task 2: Success Toast Service

**Files:**
- Create: `lib/core/services/success_toast_service.dart`

- [ ] **Step 1: Create SuccessToastService**

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SuccessToastService {
  static final SuccessToastService _instance = SuccessToastService._internal();
  static SuccessToastService get instance => _instance;
  SuccessToastService._internal();

  void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: actionLabel != null ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction ?? () {},
        ) : null,
      ),
    );
  }

  // Preset methods
  void saved(BuildContext context, [String? itemName]) =>
      show(context, itemName != null ? '$itemName berhasil disimpan' : 'Data berhasil disimpan');

  void deleted(BuildContext context, [String? itemName]) =>
      show(context, itemName != null ? '$itemName berhasil dihapus' : 'Data berhasil dihapus');

  void added(BuildContext context, [String? itemName]) =>
      show(context, itemName != null ? '$itemName berhasil ditambahkan' : 'Data berhasil ditambahkan');

  void updated(BuildContext context, [String? itemName]) =>
      show(context, itemName != null ? '$itemName berhasil diperbarui' : 'Data berhasil diperbarui');
}
```

- [ ] **Step 2: Test toast displays**

```bash
flutter run
# Add a temporary test button in any screen to verify toast works
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/success_toast_service.dart
git commit -m "feat(core): add SuccessToastService with preset methods (saved, deleted, added, updated)"
```

---

## Task 3: Loading Overlay

**Files:**
- Create: `lib/core/widgets/loading_overlay.dart`
- Create: `lib/core/widgets/list_item_shimmer.dart` (optional)

- [ ] **Step 1: Create LoadingOverlay widget**

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingOverlay({
    this.message,
    this.isFullScreen = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isFullScreen
          ? AppTheme.backgroundColor.withValues(alpha: 0.8)
          : Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create ListItemShimmer helper**

```dart
import 'package:flutter/material.dart';
import 'shimmer_loading.dart';
import 'modern_card.dart';

class ListItemShimmer extends StatelessWidget {
  final int itemCount;

  const ListItemShimmer({this.itemCount = 5, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (_, __) => ShimmerLoading(
        child: ModernCard(
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/loading_overlay.dart lib/core/widgets/list_item_shimmer.dart
git commit -m "feat(core): add LoadingOverlay and ListItemShimmer widgets"
```

---

## Task 4: Validated Text Field

**Files:**
- Create: `lib/core/widgets/validated_text_field.dart`

- [ ] **Step 1: Create ValidatedTextField widget**

```dart
import 'package:flutter/material.dart';
import 'dart:async';

class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final String? helperText;
  final bool enabled;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final int debounceMs;

  const ValidatedTextField({
    required this.label,
    this.validator,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.helperText,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
    this.debounceMs = 300,
    super.key,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  Timer? _debounce;
  String? _errorText;
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _errorText = null;
      _isValid = false;
    });

    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      setState(() {
        _errorText = widget.validator?.call(_controller.text);
        _isValid = _errorText == null && _controller.text.isNotEmpty;
      });
    });

    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      value: _errorText ?? _controller.text,
      child: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.helperText,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: _isValid
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : null,
          errorText: _errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444)),
          ),
        ),
      ),
    );
  }
}

// Built-in validators
class FieldValidators {
  static String? required(String? value) =>
      value?.isEmpty ?? true ? 'Field ini wajib diisi' : null;

  static String? email(String? value) =>
      value?.contains('@') ?? false ? null : 'Email tidak valid';

  static String? positiveNumber(String? value) {
    final num = double.tryParse(value ?? '');
    return (num == null || num <= 0) ? 'Nilai harus lebih dari 0' : null;
  }

  static String? phone(String? value) {
    final digitsOnly = value?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    return digitsOnly.length >= 10 ? null : 'Nomor telepon tidak valid';
  }

  static String? minLen(int min) {
    return (String? value) {
      return (value?.length ?? 0) < min ? 'Minimal $min karakter' : null;
    };
  }
}
```

- [ ] **Step 2: Test validation works**

```bash
flutter run
# Test field shows error for invalid input, checkmark for valid
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/validated_text_field.dart
git commit -m "feat(core): add ValidatedTextField with real-time validation and FieldValidators"
```

---

## Task 5: Search Results State Widget

**Files:**
- Create: `lib/core/widgets/search_results_state.dart`

- [ ] **Step 1: Create SearchResultsState widget**

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchResultsState extends StatelessWidget {
  final int resultCount;
  final String query;
  final List<String> activeFilters;
  final VoidCallback? onClearFilters;
  final bool isLoading;
  final Widget child;

  const SearchResultsState({
    required this.resultCount,
    required this.query,
    this.activeFilters = const [],
    this.onClearFilters,
    this.isLoading = false,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$resultCount hasil untuk "$query"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (activeFilters.isNotEmpty || onClearFilters != null)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear Filters'),
                ),
            ],
          ),
        ),
        // Active filters chips
        if (activeFilters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              children: activeFilters
                  .map((filter) => Chip(
                        label: Text(filter),
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: onClearFilters,
                      ))
                  .toList(),
            ),
          ),
        // Content
        Expanded(child: child),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/search_results_state.dart
git commit -m "feat(core): add SearchResultsState widget with count and filter display"
```

---

## Task 6: Contextual Error Display

**Files:**
- Create: `lib/core/widgets/contextual_error_display.dart`

- [ ] **Step 1: Create ContextualErrorDisplay widget**

```dart
import 'package:flutter/material.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import '../theme/app_theme.dart';

enum ErrorType {
  validation,
  notFound,
  database,
  unknown,
}

class ContextualErrorDisplay extends StatelessWidget {
  final Object error;
  final ErrorType type;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? customMessage;

  const ContextualErrorDisplay({
    required this.error,
    required this.type,
    this.onRetry,
    this.onBack,
    this.customMessage,
    super.key,
  });

  factory ContextualErrorDisplay.auto({
    required Object error,
    VoidCallback? onRetry,
    VoidCallback? onBack,
    String? customMessage,
  }) {
    ErrorType detectedType = ErrorType.unknown;

    if (error is ValidationException) detectedType = ErrorType.validation;
    else if (error is NotFoundException) detectedType = ErrorType.notFound;
    else if (error is DatabaseException) detectedType = ErrorType.database;
    else if (error is ConflictException) detectedType = ErrorType.validation;
    else if (error is InsufficientStockException) detectedType = ErrorType.validation;
    else if (error is EmptyCartException) detectedType = ErrorType.validation;

    return ContextualErrorDisplay(
      error: error,
      type: detectedType,
      onRetry: onRetry,
      onBack: onBack,
      customMessage: customMessage,
    );
  }

  IconData get _icon {
    switch (type) {
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.unknown:
        return Icons.error;
    }
  }

  Color get _color {
    switch (type) {
      case ErrorType.validation:
        return AppTheme.errorColor;
      case ErrorType.notFound:
        return AppTheme.infoColor;
      case ErrorType.database:
        return AppTheme.errorColor;
      case ErrorType.unknown:
        return AppTheme.errorColor;
    }
  }

  String get _message {
    if (customMessage != null) return customMessage!;
    if (error is AppException) return (error as AppException).userMessage;

    switch (type) {
      case ErrorType.validation:
        return 'Periksa input Anda';
      case ErrorType.notFound:
        return 'Data tidak ditemukan';
      case ErrorType.database:
        return 'Terjadi kesalahan database';
      case ErrorType.unknown:
        return 'Terjadi kesalahan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 64, color: _color),
            const SizedBox(height: 16),
            Text(
              _message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onBack != null)
                  ModernSecondaryButton(
                    text: 'Kembali',
                    icon: Icons.arrow_back,
                    onPressed: onBack,
                  ),
                if (onBack != null && onRetry != null) const SizedBox(width: 12),
                if (onRetry != null)
                  ModernButton(
                    text: 'Coba Lagi',
                    icon: Icons.refresh,
                    onPressed: onRetry,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/contextual_error_display.dart
git commit -m "feat(core): add ContextualErrorDisplay with auto-detection for AppException types"
```

---

## Task 7: Profit Report Entity

**Files:**
- Create: `lib/features/expenses/domain/entities/profit_report.dart`

- [ ] **Step 1: Create ProfitReport entity**

```dart
class ProfitReport {
  final double grossProfit;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final double expenseRatio;

  const ProfitReport({
    required this.grossProfit,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.expenseRatio,
  });

  @override
  List<Object> get props => [
    grossProfit,
    totalRevenue,
    totalExpenses,
    netProfit,
    profitMargin,
    expenseRatio,
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/domain/entities/profit_report.dart
git commit -m "feat(expenses): add ProfitReport entity"
```

---

## Task 8: Get Expense Count By Category Use Case

**Files:**
- Create: `lib/features/expenses/domain/usecases/get_expense_count_by_category_usecase.dart'

- [ ] **Step 1: Create GetExpenseCountByCategoryUseCase**

```dart
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseCountByCategoryUseCase {
  final ExpenseRepository repository;

  GetExpenseCountByCategoryUseCase({required this.repository});

  Future<Map<String, int>> execute() async {
    try {
      // Get all expenses and count by category
      final expenses = await repository.getExpenses();

      final Map<String, int> counts = {};
      for (final expense in expenses) {
        counts[expense.category] = (counts[expense.category] ?? 0) + 1;
      }

      return counts;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to load category counts: $e');
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/domain/usecases/get_expense_count_by_category_usecase.dart
git commit -m "feat(expenses): add GetExpenseCountByCategoryUseCase"
```

---

## Task 9: Extend ExpenseController

**IMPORTANT**: This task MUST be completed before Tasks 12-16 (widgets) because those widgets depend on the controller properties added here.

**Files:**
- Modify: `lib/features/expenses/presentation/controllers/expense_controller.dart`

- [ ] **Step 1: Read existing controller to understand structure**

```bash
# Read the file to see existing state and methods
```

- [ ] **Step 2: Add new state getters and methods to controller**

Add these after existing state:

```dart
// NEW: Category counts
Map<String, int> _categoryCounts = {};
Map<String, int> get categoryCounts => _categoryCounts;

// NEW: Summary data
Map<String, double> _categorySummary = {};
Map<String, double> get categorySummary => _categorySummary;

double _totalExpenses = 0;
double get totalExpenses => _totalExpenses;

double? _periodComparison;
double? get periodComparison => _periodComparison;

// NEW: Filter state
String? _activeFilterCategory;
String? get activeFilterCategory => _activeFilterCategory;

DateTimeRange? _selectedDateRange;
DateTimeRange? get selectedDateRange => _selectedDateRange;
```

Add new methods:

```dart
Future<void> loadCategoryCounts() async {
  try {
    _setLoading(true);
    _clearError();
    _categoryCounts = await _getExpenseCountByCategoryUseCase.execute();
  } on AppException catch (e) {
    _setError(e);
  } finally {
    _setLoading(false);
  }
}

Future<void> loadSummary(DateTimeRange range) async {
  try {
    _setLoading(true);
    _clearError();
    _selectedDateRange = range;

    final summary = await getExpenseSummaryUseCase.execute(
      startDate: range.start,
      endDate: range.end,
    );

    _categorySummary = summary['byCategory'] ?? {};
    _totalExpenses = summary['total'] ?? 0.0;

    // Calculate period comparison
    final prevSummary = await getExpenseSummaryUseCase.execute(
      startDate: range.start.subtract(const Duration(days: 30)),
      endDate: range.start,
    );
    final prevTotal = prevSummary['total'] ?? 0.0;
    if (prevTotal > 0) {
      _periodComparison = ((_totalExpenses - prevTotal) / prevTotal) * 100;
    }
  } on AppException catch (e) {
    _setError(e);
  } finally {
    _setLoading(false);
  }
}

void setCategoryFilter(String? categoryId) {
  _activeFilterCategory = categoryId;
  notifyListeners();
  loadExpenses();
}

void setDateRange(DateTimeRange? range) {
  _selectedDateRange = range;
  notifyListeners();
  loadExpenses();
}

void clearFilters() {
  _activeFilterCategory = null;
  _selectedDateRange = null;
  notifyListeners();
  loadExpenses();
}
```

Update constructor to accept new use cases (modify existing):

```dart
ExpenseController({
    required this.addExpenseUseCase,
    required this.getExpensesUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getExpenseSummaryUseCase,
    required GetExpenseCountByCategoryUseCase getExpenseCountByCategoryUseCase,
    required GetProfitReportUseCase getProfitReportUseCase,
  })  : _getExpenseCountByCategoryUseCase = getExpenseCountByCategoryUseCase,
       _getProfitReportUseCase = getProfitReportUseCase;
```

Add private fields:

```dart
final GetExpenseCountByCategoryUseCase _getExpenseCountByCategoryUseCase;
final GetProfitReportUseCase _getProfitReportUseCase;
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/expenses/presentation/controllers/expense_controller.dart
git commit -m "feat(expenses): extend ExpenseController with summary, filters, and category counts"
```

---

## Task 10: Get Profit Report Use Case

**Files:**
- Create: `lib/features/expenses/domain/usecases/get_profit_report_usecase.dart'

- [ ] **Step 1: Create GetProfitReportUseCase**

```dart
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/expenses/domain/entities/profit_report.dart';
import 'package:simple_pos/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_pos/features/sales/domain/repositories/transaction_repository.dart';

class GetProfitReportUseCase {
  final ExpenseRepository expenseRepository;
  final TransactionRepository transactionRepository;

  GetProfitReportUseCase({
    required this.expenseRepository,
    required this.transactionRepository,
  });

  Future<ProfitReport> execute(DateTimeRange range) async {
    try {
      // Get transactions for the period to calculate gross profit and revenue
      final transactions = await transactionRepository.getTransactions(
        startDate: range.start,
        endDate: range.end,
      );

      double totalRevenue = 0;
      double grossProfit = 0;

      for (final tx in transactions) {
        totalRevenue += tx.totalAmount;
        grossProfit += tx.profit;
      }

      // Get total expenses
      final expenses = await expenseRepository.getExpenses(
        startDate: range.start,
        endDate: range.end,
      );

      final totalExpenses = expenses.fold<double>(
        0,
        (sum, e) => sum + e.amount,
      );

      // Calculate
      final netProfit = grossProfit - totalExpenses;
      final profitMargin = totalRevenue > 0 ? netProfit / totalRevenue : 0;
      final expenseRatio = totalRevenue > 0 ? totalExpenses / totalRevenue : 0;

      return ProfitReport(
        grossProfit: grossProfit,
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
        netProfit: netProfit,
        profitMargin: profitMargin,
        expenseRatio: expenseRatio,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to generate profit report: $e');
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/domain/usecases/get_profit_report_usecase.dart
git commit -m "feat(expenses): add GetProfitReportUseCase for profit calculation"
```

---

## Task 11: Expense Category Helper

**Files:**
- Create: `lib/features/expenses/presentation/utils/expense_category_helper.dart'

- [ ] **Step 1: Create ExpenseCategoryHelper utility**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/expenses/domain/entities/expense_categories.dart';

class ExpenseCategoryHelper {
  static Color getCategoryColor(ExpenseCategory category) {
    return switch (category.colorName.toLowerCase()) {
      'red' => AppTheme.errorColor,
      'green' => AppTheme.successColor,
      'blue' => AppTheme.infoColor,
      'yellow' => AppTheme.warningColor,
      'purple' => const Color(0xFF9333EA),
      'orange' => const Color(0xFFF97316),
      'teal' => AppTheme.secondaryColor,
      'pink' => const Color(0xFFEC4899),
      _ => AppTheme.textSecondary,
    };
  }

  static IconData getCategoryIcon(ExpenseCategory category) {
    return switch (category.iconName) {
      'home' => Icons.home,
      'bolt' => Icons.bolt,
      'inventory' => Icons.inventory_2,
      'build' => Icons.build,
      'payments' => Icons.payments,
      'list' => Icons.list,
      _ => Icons.receipt_long,
    };
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/utils/expense_category_helper.dart
git commit -m "feat(expenses): add ExpenseCategoryHelper for color/icon mapping"
```

---

## Task 12: Expense Filter Bar

**Files:**
- Create: `lib/features/expenses/presentation/widgets/expense_filter_bar.dart'

- [ ] **Step 1: Create ExpenseFilterBar widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../expenses/domain/entities/expense_categories.dart';

class ExpenseFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final VoidCallback? onClearFilters;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  const ExpenseFilterBar({
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    this.dateRange,
    this.onClearFilters,
    super.key,
  });

  String _formatDateRange(DateTimeRange range) {
    final start = '${range.start.day}/${range.start.month}/${range.start.year}';
    final end = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategory != null || dateRange != null;

    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: selectedCategory == null,
                onSelected: (_) => onCategoryChanged(null),
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                selectedColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              ...ExpenseCategories.predefined.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: selectedCategory == cat.id,
                      onSelected: (_) => onCategoryChanged(
                        selectedCategory == cat.id ? null : cat.id,
                      ),
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      selectedColor: AppTheme.primaryColor,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Date range and clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Date range selector
              ModernCard(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    initialDateRange: dateRange,
                  );
                  if (picked != null) {
                    onDateRangeChanged(picked);
                  }
                },
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      dateRange != null
                          ? _formatDateRange(dateRange!)
                          : 'Pilih Rentang Tanggal',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (hasFilters)
                TextButton.icon(
                  onPressed: () {
                    onCategoryChanged(null);
                    onDateRangeChanged(null);
                    onClearFilters?.call();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/widgets/expense_filter_bar.dart
git commit -m "feat(expenses): add ExpenseFilterBar with category chips and date range"
```

---

## Task 13: Expense Card Widget

**Files:**
- Create: `lib/features/expenses/presentation/widgets/expense_card.dart'

- [ ] **Step 1: Create ExpenseCard widget with swipe actions**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/utils/expense_category_helper.dart';
import '../../../expenses/domain/entities/expense_categories.dart';

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

  ExpenseCategory get _category =>
      ExpenseCategories.all.firstWhere((c) => c.id == expense.category);

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
                color: ExpenseCategoryHelper.getCategoryColor(_category),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: ExpenseCategoryHelper.getCategoryColor(_category),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.description,
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

  String _getPaymentMethodLabel(ExpensePaymentMethod method) {
    return switch (method) {
      ExpensePaymentMethod.cash => 'Tunai',
      ExpensePaymentMethod.transfer => 'Transfer',
      ExpensePaymentMethod.card => 'Kartu',
      ExpensePaymentMethod.other => 'Lainnya',
    };
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
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/widgets/expense_card.dart
git commit -m "feat(expenses): add ExpenseCard with slidable edit/delete actions"
```

---

## Task 14: Expense List Tab

**Files:**
- Create: `lib/features/expenses/presentation/widgets/expense_list_tab.dart'

- [ ] **Step 1: Create ExpenseListTab widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/contextual_error_display.dart';
import '../controllers/expense_controller.dart';
import 'expense_filter_bar.dart';
import 'expense_card.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpenseFilterBar(
          selectedCategory: widget.controller.activeFilterCategory,
          dateRange: widget.controller.selectedDateRange,
          onCategoryChanged: widget.controller.setCategoryFilter,
          onDateRangeChanged: widget.controller.setDateRange,
          onClearFilters: widget.controller.clearFilters,
        ),
        Expanded(
          child: Consumer<ExpenseController>(
            builder: (context, controller, _) {
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
                      onDelete: () => controller.deleteExpense(expenses[index].id),
                      onViewReceipt: expenses[index].receiptImagePath != null
                          ? () => _showReceiptImage(context, expenses[index].receiptImagePath!)
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    // TODO: Implement add expense dialog
  }

  void _showEditDialog(BuildContext context, Expense expense) {
    // TODO: Implement edit expense dialog
  }

  void _showReceiptImage(BuildContext context, String imagePath) {
    // TODO: Implement receipt image viewer
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/widgets/expense_list_tab.dart
git commit -m "feat(expenses): add ExpenseListTab with filters and expense list"
```

---

## Task 15: Expense Summary Tab

**Files:**
- Create: `lib/features/expenses/presentation/widgets/expense_summary_tab.dart'

- [ ] **Step 1: Create ExpenseSummaryTab widget**

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/widgets/animated_empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/sales/presentation/widgets/summary_stat_card.dart';
import '../controllers/expense_controller.dart';

class ExpenseSummaryTab extends StatefulWidget {
  final ExpenseController controller;

  const ExpenseSummaryTab({required this.controller, super.key});

  @override
  State<ExpenseSummaryTab> createState() => _ExpenseSummaryTabState();
}

class _ExpenseSummaryTabState extends State<ExpenseSummaryTab> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectPeriod(_getThisMonthRange());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PeriodSelector(
          selected: _selectedRange,
          onPeriodSelected: (range) {
            setState(() => _selectedRange = range);
            widget.controller.loadSummary(range);
          },
        ),
        Expanded(
          child: Consumer<ExpenseController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                );
              }

              if (controller.totalExpenses == 0) {
                return AnimatedEmptyState(
                  icon: Icons.bar_chart,
                  title: 'Belum Ada Data',
                  subtitle: 'Pilih periode untuk melihat ringkasan pengeluaran',
                );
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryStatCard(
                          title: 'Total Pengeluaran',
                          value: CurrencyFormatter.format(controller.totalExpenses),
                          icon: Icons.payments,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryStatCard(
                          title: 'Periode Lalu',
                          value: controller.periodComparison != null
                              ? '${controller.periodComparison!.toStringAsFixed(0)}%'
                              : '-',
                          icon: controller.periodComparison != null &&
                                  controller.periodComparison! >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: controller.periodComparison != null &&
                                  controller.periodComparison! >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Category breakdown
                  _CategoryBreakdownChart(
                    categorySummary: controller.categorySummary,
                  ),
                  const SizedBox(height: 24),
                  // Payment method breakdown
                  _PaymentMethodChart(
                    expenses: controller.expenses,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final DateTimeRange? selected;
  final ValueChanged<DateTimeRange> onPeriodSelected;

  const _PeriodSelector({
    required this.selected,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          _PeriodChip(
            label: 'Hari Ini',
            isSelected: selected != null &&
                _isSameDay(selected!.start, DateTime.now()),
            onTap: () => onPeriodSelected(_getTodayRange()),
          ),
          _PeriodChip(
            label: 'Minggu Ini',
            isSelected: selected != null &&
                _isSameWeek(selected!.start, DateTime.now()),
            onTap: () => onPeriodSelected(_getThisWeekRange()),
          ),
          _PeriodChip(
            label: 'Bulan Ini',
            isSelected: selected != null &&
                selected!.start.month == DateTime.now().month &&
                selected!.start.year == DateTime.now().year,
            onTap: () => onPeriodSelected(_getThisMonthRange()),
          ),
          _PeriodChip(
            label: 'Custom',
            isSelected: false,
            onTap: () => _showCustomRangePicker(context, onPeriodSelected),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameWeek(DateTime a, DateTime b) {
    final weekA = a.difference(DateTime(a.year - 1)).inDays ~/ 7;
    final weekB = b.difference(DateTime(b.year - 1)).inDays ~/ 7;
    return weekA == weekB;
  }

  DateTimeRange _getTodayRange() {
    final now = DateTime.now();
    return DateTimeRange(start: DateTime(now.year, now.month, now.day), end: now);
  }

  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return DateTimeRange(
      start: DateTime(start.year, start.month, start.day),
      end: now,
    );
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  Future<void> _showCustomRangePicker(
    BuildContext context,
    ValueChanged<DateTimeRange> onSelected,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.withValues(alpha: 0.1),
      selectedColor: AppTheme.primaryColor,
    );
  }
}

class _CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> categorySummary;

  const _CategoryBreakdownChart({required this.categorySummary});

  @override
  Widget build(BuildContext context) {
    if (categorySummary.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categorySummary.values.fold<double>(0, (sum, v) => sum + v);
    final categories = categorySummary.entries.toList();

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Per Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ...categories.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 14)),
                      Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentMethodChart extends StatelessWidget {
  final List<dynamic> expenses;

  const _PaymentMethodChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by payment method
    final Map<String, double> methodTotals = {};
    for (final expense in expenses) {
      final method = expense.paymentMethod.toString();
      methodTotals[method] = (methodTotals[method] ?? 0) + expense.amount;
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          // Simple pie chart representation
          ...methodTotals.entries.map((entry) {
            final total = methodTotals.values.fold<double>(0, (sum, v) => sum + v);
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getMethodColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_getMethodLabel(entry.key))),
                  Text('${percentage.toStringAsFixed(1)}%'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    return switch (method) {
      'ExpensePaymentMethod.cash' => AppTheme.successColor,
      'ExpensePaymentMethod.transfer' => AppTheme.primaryColor,
      'ExpensePaymentMethod.card' => AppTheme.infoColor,
      _ => AppTheme.warningColor,
    };
  }

  String _getMethodLabel(String method) {
    return switch (method) {
      'ExpensePaymentMethod.cash' => 'Tunai',
      'ExpensePaymentMethod.transfer' => 'Transfer',
      'ExpensePaymentMethod.card' => 'Kartu',
      _ => 'Lainnya',
    };
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/widgets/expense_summary_tab.dart
git commit -m "feat(expenses): add ExpenseSummaryTab with KPI cards and charts"
```

---

## Task 16: Expense Categories Tab

**Files:**
- Create: `lib/features/expenses/presentation/widgets/expense_categories_tab.dart'

- [ ] **Step 1: Create ExpenseCategoriesTab widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/contextual_error_display.dart';
import '../../../expenses/domain/entities/expense_categories.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseController>(
      builder: (context, controller, _) {
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
              final count = counts[cat.id] ?? 0;
              return _CategoryCard(
                category: cat,
                expenseCount: count,
              );
            }),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final int expenseCount;

  const _CategoryCard({
    required this.category,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ExpenseCategoryHelper.getCategoryColor(category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ExpenseCategoryHelper.getCategoryIcon(category),
              color: ExpenseCategoryHelper.getCategoryColor(category),
            ),
          ),
          const SizedBox(width: 16),
          // Name and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/widgets/expense_categories_tab.dart
git commit -m "feat(expenses): add ExpenseCategoriesTab showing predefined categories with counts"
```

---

## Task 17: Expense Screen (Main)

**Files:**
- Create: `lib/features/expenses/presentation/screens/expense_screen.dart'

- [ ] **Step 1: Create ExpenseScreen with 3 tabs**

```dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/contextual_error_display.dart';
import '../../../../shared/presentation/main_navigation.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_list_tab.dart';
import '../widgets/expense_summary_tab.dart';
import '../widgets/expense_categories_tab.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTab = _tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpenseController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daftar', icon: Icon(Icons.list)),
            Tab(text: 'Ringkasan', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Kategori', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          ExpenseListTab(controller: controller),
          ExpenseSummaryTab(controller: controller),
          ExpenseCategoriesTab(controller: controller),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    // TODO: Implement add expense dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur tambah pengeluaran akan diimplementasikan')),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/screens/expense_screen.dart
git commit -m "feat(expenses): add ExpenseScreen with 3 tabs (List, Summary, Categories)"
```

---

## Task 18: Navigation Integration (Drawer)

**Files:**
- Modify: `lib/features/shared/presentation/drawer_sections.dart`
- Modify: `lib/features/shared/presentation/main_navigation.dart`

- [ ] **Step 1: Add DrawerExpensesItem to drawer_sections.dart**

```dart
class DrawerExpensesItem extends StatelessWidget {
  const DrawerExpensesItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpenseScreen()),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Icon(Icons.receipt_long, color: AppTheme.secondaryColor),
          SizedBox(width: 12),
          Text('Pengeluaran', style: TextStyle(fontSize: 15)),
          Spacer(),
          Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
        ],
      ),
    );
  }
}
```

Add import:
```dart
import '../../expenses/presentation/screens/expense_screen.dart';
```

- [ ] **Step 2: Add DrawerExpensesItem to main_navigation.dart drawer**

Find the drawer's ListView and add after `DrawerLowStockItem`:

```dart
const DrawerExpensesItem(),
```

Add import if needed:
```dart
import '../presentation/drawer_sections.dart';
```

- [ ] **Step 3: Test navigation works**

```bash
flutter run
# Open drawer, tap on "Pengeluaran", verify screen opens
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/shared/presentation/drawer_sections.dart lib/features/shared/presentation/main_navigation.dart
git commit -m "feat(nav): add Expenses drawer menu item"
```

---

## Task 19: DI Configuration in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add new use cases to main.dart**

Add after existing expense use cases:

```dart
// New expense use cases
ProxyProvider<ExpenseRepositoryImpl, GetExpenseCountByCategoryUseCase>(
  update: (_, repo, __) => GetExpenseCountByCategoryUseCase(repository: repo),
),

ProxyProvider2<ExpenseRepositoryImpl, TransactionRepository, GetProfitReportUseCase>(
  update: (_, expenseRepo, transactionRepo, __) => GetProfitReportUseCase(
    expenseRepository: expenseRepo,
    transactionRepository: transactionRepo,
  ),
),
```

- [ ] **Step 2: Update ExpenseController ProxyProvider to ChangeNotifierProxyProvider7**

Change existing `ChangeNotifierProxyProviderX` to include new use cases:

```dart
ChangeNotifierProxyProvider7<
  AddExpenseUseCase,
  GetExpensesUseCase,
  UpdateExpenseUseCase,
  DeleteExpenseUseCase,
  GetExpenseSummaryUseCase,
  GetExpenseCountByCategoryUseCase,
  GetProfitReportUseCase,
  ExpenseController
>(
  update: (_, addExp, getExp, updExp, delExp, getSum, getCount, getProfit, __) =>
      ExpenseController(
    addExpenseUseCase: addExp,
    getExpensesUseCase: getExp,
    updateExpenseUseCase: updExp,
    deleteExpenseUseCase: delExp,
    getExpenseSummaryUseCase: getSum,
    getExpenseCountByCategoryUseCase: getCount,
    getProfitReportUseCase: getProfit,
  ),
),
```

Add imports:

```dart
import 'package:simple_pos/features/expenses/domain/usecases/get_expense_count_by_category_usecase.dart';
import 'package:simple_pos/features/expenses/domain/usecases/get_profit_report_usecase.dart';
```

- [ ] **Step 3: Test app runs without DI errors**

```bash
flutter run
# Verify app starts, Expenses screen accessible
```

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "feat(di): add GetExpenseCountByCategory and GetProfitReport use cases to DI"
```

---

## Task 20: Sales Report Profit Integration

**Files:**
- Modify: `lib/features/sales/presentation/screens/reports_screen.dart`

- [ ] **Step 1: Add GetProfitReportUseCase dependency to reports screen**

First, make sure GetProfitReportUseCase is accessible to the reports screen. It will be provided via the DI chain.

- [ ] **Step 2: Add expense toggle and profit display state**

Add state variables:
```dart
bool _includeExpenses = false;
ProfitReport? _profitReport;
```

- [ ] **Step 3: Add expense toggle UI and net profit display**

Add to profit section (after existing profit cards):
```dart
// Expense toggle
ModernCard(
  child: SwitchListTile(
    title: const Text('Sertakan pengeluaran dalam profit'),
    subtitle: const Text('Hitung profit bersih setelah dikurangi pengeluaran'),
    value: _includeExpenses,
    onChanged: (value) {
      setState(() => _includeExpenses = value);
      _loadReport();
    },
  ),
),

// Net profit display when enabled
if (_includeExpenses && _profitReport != null) ...[
  const SizedBox(height: 12),
  SummaryStatCard(
    title: 'Profit Bersih',
    value: CurrencyFormatter.format(_profitReport!.netProfit),
    icon: Icons.account_balance_wallet,
    color: AppTheme.successColor,
  ),
  const SizedBox(height: 12),
  ModernCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rincian Pengeluaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text('Total: ${CurrencyFormatter.format(_profitReport!.totalExpenses)}'),
        Text('Rasio: ${(_profitReport!.expenseRatio * 100).toStringAsFixed(1)}% dari pendapatan'),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Lihat Detail Pengeluaran'),
        ),
      ],
    ),
  ),
],
```

Add imports:
```dart
import 'package:simple_pos/features/expenses/domain/entities/profit_report.dart';
import 'package:simple_pos/features/expenses/presentation/screens/expense_screen.dart';
```

- [ ] **Step 4: Update _loadReport to fetch profit report when toggle is on**

Modify existing `_loadReport` method to include profit calculation when `_includeExpenses` is true. You'll need to access GetProfitReportUseCase - this will be passed to the screen or accessed via context.

```dart
if (_includeExpenses) {
  final profitReport = await getProfitReportUseCase.execute(range);
  setState(() => _profitReport = profitReport);
}
```

- [ ] **Step 5: Test integration**

```bash
flutter run
# Open Sales Report, enable expense toggle, verify net profit displays
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/sales/presentation/screens/reports_screen.dart
git commit -m "feat(reports): add expense toggle and net profit calculation"
```

---

## Task 21: Expense Form Dialog with Receipt Handling

**Files:**
- Create: `lib/features/expenses/presentation/widgets/expense_form_dialog.dart`

- [ ] **Step 1: Create ExpenseFormDialog widget**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/validated_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_secondary_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_categories.dart';
import '../../../expenses/domain/entities/expense_payment_method.dart';
import '../controllers/expense_controller.dart';

class ExpenseFormDialog extends StatefulWidget {
  final Expense? expense; // null for add, non-null for edit
  final ExpenseController controller;

  const ExpenseFormDialog({
    this.expense,
    required this.controller,
    super.key,
  });

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController(text: DateTime.now().toLocal().split(' ')[0]);

  String? _selectedCategoryId;
  ExpensePaymentMethod _selectedPaymentMethod = ExpensePaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  String? _receiptImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedCategoryId = widget.expense!.category;
      _selectedPaymentMethod = widget.expense!.paymentMethod;
      _selectedDate = widget.expense!.date;
      _receiptImagePath = widget.expense!.receiptImagePath;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      child: ModernCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      widget.expense == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Amount
                ValidatedTextField(
                  label: 'Jumlah',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  validator: FieldValidators.required,
                  helperText: 'Contoh: 150000',
                ),
                const SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: ExpenseCategories.predefined.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategoryId = value),
                ),
                const SizedBox(height: 16),

                // Description
                ValidatedTextField(
                  label: 'Deskripsi',
                  controller: _descriptionController,
                  maxLines: 2,
                  validator: FieldValidators.required,
                ),
                const SizedBox(height: 16),

                // Payment method
                const Text('Metode Pembayaran', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ExpensePaymentMethod.values.map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return ChoiceChip(
                      label: _getPaymentMethodLabel(method),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedPaymentMethod = method),
                      selectedColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_formatDate(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),

                // Receipt photo
                Row(
                  children: [
                    Expanded(
                      child: _receiptImagePath != null
                          ? ModernCard(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _receiptImagePath!.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () => setState(() => _receiptImagePath = null),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            )
                          : const Text('Belum ada bukti struk'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _pickReceiptImage(context),
                      icon: const Icon(Icons.camera_alt),
                      label: 'Foto',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ModernSecondaryButton(
                        text: 'Batal',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernButton(
                        text: widget.expense == null ? 'Simpan' : 'Simpan',
                        onPressed: _submitForm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPaymentMethodLabel(ExpensePaymentMethod method) {
    return switch (method) {
      ExpensePaymentMethod.cash => 'Tunai',
      ExpensePaymentMethod.transfer => 'Transfer',
      ExpensePaymentMethod.card => 'Kartu',
      ExpensePaymentMethod.other => 'Lainnya',
    };
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickReceiptImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      // TODO: Save to app documents directory
      // For now, just store the path
      setState(() => _receiptImagePath = image.path);
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus lebih dari 0')),
      );
      return;
    }

    final expense = Expense(
      id: widget.expense?.id ?? 0,
      amount: amount,
      category: _selectedCategoryId!,
      description: _descriptionController.text,
      paymentMethod: _selectedPaymentMethod,
      date: _selectedDate,
      receiptImagePath: _receiptImagePath,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.expense == null) {
        await widget.controller.addExpense(expense);
      } else {
        await widget.controller.updateExpense(expense);
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/expenses/presentation/widgets/expense_form_dialog.dart
git commit -m "feat(expenses): add ExpenseFormDialog with amount, category, description, payment method, date, and receipt photo"
```

---

## Completion Checklist

- [ ] All 6 UI improvement widgets created and working (Tasks 1-6)
- [ ] All domain layer entities and use cases created (Tasks 7-8, 10)
- [ ] ExpenseController extended with new properties (Task 9)
- [ ] Expense Category Helper created (Task 11)
- [ ] All expense presentation widgets created (Tasks 12-17)
- [ ] Navigation to Expenses screen works (Task 18)
- [ ] DI configuration updated (Task 19)
- [ ] Sales report integrates expense data (Task 20)
- [ ] Expense form dialog with receipt handling (Task 21)
- [ ] No compile or runtime errors
- [ ] Dark mode compatible for all new components

---

## References

- Specs: `docs/superpowers/specs/2025-03-17-ui-improvements-design.md`
- Spec: `docs/superpowers/specs/2025-03-17-expenses-ui-design.md`
- AppTheme: `lib/core/theme/app_theme.dart`
- Exceptions: `lib/core/exceptions/app_exceptions.dart`
- Existing widgets: `lib/core/widgets/`
