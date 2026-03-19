# Expenses UI Design

**Date**: 2025-03-17
**Feature**: Expense Tracking User Interface
**Status**: Design v3 (Final)

---

## Overview

Create a comprehensive expense tracking UI for the Minimarket POS system. The backend (domain + data layers) is already implemented with database schema, entities, repositories, and use cases. This design focuses solely on the presentation layer.

---

## Screen Structure

### Single Screen with Three Tabs

**File**: `lib/features/expenses/presentation/screens/expense_screen.dart`

```
┌─────────────────────────────────────────────────────────────┐
│  Expenses                             [Filter] [Search]     │
├─────────────────────────────────────────────────────────────┤
│  [List] [Summary] [Categories]                              │
├─────────────────────────────────────────────────────────────┤
│  (Tab Content)                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Navigation Integration

### New Drawer Section Widget

**File**: `lib/features/shared/presentation/drawer_sections.dart`

Add a new `DrawerExpensesItem` widget following the pattern of `DrawerLowStockItem`:

```dart
class DrawerExpensesItem extends StatelessWidget {
  const DrawerExpensesItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
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

**Modify**: `lib/features/shared/presentation/main_navigation.dart`
- Add `DrawerExpensesItem()` to the drawer's ListView after `DrawerLowStockItem`

---

## Tab 1: Expense List

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ Filter: [All ▼]  This Month [Clear]                         │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Listrik & Air           Rp 150.000        [Photo]       │ │
│ │ PLN Juni               Transfer           Jun 15        │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Perlengkapan            Rp 45.000                       │ │
│ │ Kertas struk           Cash               Jun 14        │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Filter Bar Widget

**File**: `lib/features/expenses/presentation/widgets/expense_filter_bar.dart`

```dart
class ExpenseFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final VoidCallback? onClearFilters;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  // Shows horizontal chips for categories and date range button
  // "Clear" button appears when any filter is active
}
```

### Expense Card

**File**: `lib/features/expenses/presentation/widgets/expense_card.dart`

Using `flutter_slidable` (existing dependency) for swipe actions:

```dart
Slidable(
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
        onPressed: (_) => confirmDelete(),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Hapus',
      ),
    ],
  ),
  child: ModernCard(...), // Expense content
)
```

**Swipe behavior**:
- Swipe RIGHT → reveals Edit action on the left (blue)
- Swipe LEFT → reveals Delete action on the right (red) with confirmation

### Empty State

```dart
AnimatedEmptyState(
  icon: Icons.receipt_long_outlined,
  title: 'Belum Ada Pengeluaran',
  subtitle: 'Catat pengeluaran operasional toko Anda',
  actionText: 'Tambah Pengeluaran',
  onAction: () => showAddExpenseDialog(context),
)
```

### Loading State

Use `ShimmerLoading` for list skeleton, or centered `CircularProgressIndicator`:

```dart
if (controller.isLoading) {
  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
}
```

---

## Tab 2: Summary Dashboard

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│  [Today] [This Week] [This Month] [Custom]                  │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ Total Expenses  │  │ vs Last Period  │                  │
│  │ Rp 2.695.000   │  │ +12%  ↑         │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────────────┐           │
│  │  By Category (Bar Chart - using fl_chart)   │           │
│  └─────────────────────────────────────────────┘           │
│  ┌─────────────────────────────────────────────┐           │
│  │  By Payment Method (Pie Chart)              │           │
│  └─────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

### Components

- **Period selector**: Chips for Today, This Week, This Month, Custom Range
- **KPI cards**: Use `SummaryStatCard` (from `lib/features/sales/presentation/widgets/summary_stat_card.dart`)
- **Category breakdown**: Use `fl_chart` BarChart
- **Payment breakdown**: Use `fl_chart` PieChart

### KPI Cards

```dart
Row(
  children: [
    SummaryStatCard(
      title: 'Total Pengeluaran',
      value: CurrencyFormatter.format(controller.totalExpenses),
      icon: Icons.payments,
      color: AppTheme.secondaryColor,
    ),
    SummaryStatCard(
      title: 'Periode Sebelumnya',
      value: '${controller.periodComparison >= 0 ? '+' : ''}${controller.periodComparison.toStringAsFixed(0)}%',
      icon: controller.periodComparison >= 0 ? Icons.trending_up : Icons.trending_down,
      color: controller.periodComparison >= 0 ? AppTheme.successColor : AppTheme.errorColor,
    ),
  ],
)
```

---

## Tab 3: Category Management

**Note**: Backend only supports predefined categories via `ExpenseCategories` class. Category management is READ-ONLY in this phase.

### Layout (Read-Only View)

```
┌─────────────────────────────────────────────────────────────┐
│  Expense Categories                                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🏠 Sewa                                    0 items   │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ⚡ Listrik & Air                           12 items   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Category Color Helper

**File**: `lib/features/expenses/presentation/utils/expense_category_helper.dart`

```dart
class ExpenseCategoryHelper {
  static Color getCategoryColor(String colorName) {
    return switch (colorName.toLowerCase()) {
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

  static IconData getCategoryIcon(String iconName) {
    return switch (iconName) {
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

---

## Add/Edit Expense Dialog

**File**: `lib/features/expenses/presentation/widgets/expense_form_dialog.dart`

### Form Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Tambah Pengeluaran                                  [X]    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Jumlah                                                     │
│  [Rp 150.000]                                               │
│                                                             │
│  Kategori                              [Select ▼]          │
│  [Listrik & Air]                                            │
│                                                             │
│  Deskripsi                                                  │
│  [PLN Juni 2024]                                            │
│                                                             │
│  Metode Pembayaran                                          │
│  [Cash] [Transfer] [Card] [Lainnya]                         │
│                                                             │
│  Tanggal                                  [Select Date]     │
│  [17 Juni 2024]                                             │
│                                                             │
│  Bukti Struk                                                │
│  [              ]              [Camera] [Gallery]           │
│                                                             │
│                    [Cancel]              [Save]            │
└─────────────────────────────────────────────────────────────┘
```

### Fields

| Field | Type | Validation |
|-------|------|------------|
| Amount | Currency input | Required, > 0 |
| Category | Dropdown from predefined list | Required |
| Description | Text field | Required |
| Payment Method | Cash/Transfer/Card/Other | Required |
| Date | Date picker | Required, defaults to today |
| Receipt | Camera/gallery | Optional |

### Payment Methods

Use `ExpensePaymentMethod` enum values:
- `cash` - Tunai
- `transfer` - Transfer Bank
- `card` - Kartu Kredit/Debit
- `other` - Lainnya

### Receipt Photo Implementation

**Package**: `image_picker` (already in dependencies)

```dart
// Pick image
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery, // or ImageSource.camera
  imageQuality: 80,
);

// Save to app documents directory
final Directory appDir = await getApplicationDocumentsDirectory();
final String fileName = 'expenses/receipts/${expenseId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
final String savedPath = '${appDir.path}/$fileName';
await File(image.path).copy(savedPath);

// Store path in expense.receiptImage field
```

**Display**: Use `Image.file()` for local images, show thumbnail (48x48) in list
**Viewer**: On tap, show full screen with `Hero` animation
**Cleanup**: Delete file when expense is deleted

---

## Data Flow

### Controller Extension

**File**: `lib/features/expenses/presentation/controllers/expense_controller.dart`

Add to existing controller:

```dart
class ExpenseController extends ChangeNotifier {
  // Existing state...
  List<Expense> _expenses = [];
  // ... existing fields

  // NEW: Category counts
  Map<String, int> _categoryCounts = {};
  Map<String, int> get categoryCounts => _categoryCounts;

  // NEW: Summary data
  Map<String, double> _categorySummary = {};
  Map<String, double> get categorySummary => _categorySummary;

  double _totalExpenses = 0;
  double get totalExpenses => _totalExpenses;

  double? _periodComparison; // percentage change
  double? get periodComparison => _periodComparison;

  // NEW: Filter state
  String? _activeFilterCategory;
  String? get activeFilterCategory => _activeFilterCategory;

  DateTimeRange? _selectedDateRange;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  // Existing methods...

  // NEW: Load category counts
  Future<void> loadCategoryCounts() async {
    try {
      _setLoading(true);
      _clearError();
      _categoryCounts = await getExpenseCountByCategoryUseCase.execute();
    } on AppException catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Load summary for dashboard
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

  // NEW: Filter methods
  void setCategoryFilter(String? categoryId) {
    _activeFilterCategory = categoryId;
    notifyListeners();
    loadExpenses(); // Reload with filter
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

  // Private helpers (if not already present)
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(AppException? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
```

### Error Handling Pattern

```dart
// In UI - show SnackBar on error
void _listenToErrors(BuildContext context) {
  ever(controller.error, (AppException? error) {
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.userMessage),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  });
}
```

---

## Profit Report Integration

### New Entity

**File**: `lib/features/expenses/domain/entities/profit_report.dart`

```dart
class ProfitReport {
  final double grossProfit;      // From sales (sum of price - costPrice)
  final double totalRevenue;     // Total sales
  final double totalExpenses;    // From expenses
  final double netProfit;        // grossProfit - totalExpenses
  final double profitMargin;     // netProfit / totalRevenue
  final double expenseRatio;     // totalExpenses / totalRevenue

  const ProfitReport({
    required this.grossProfit,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.expenseRatio,
  });
}
```

### New Use Case

**File**: `lib/features/expenses/domain/usecases/get_profit_report_usecase.dart`

```dart
class GetProfitReportUseCase {
  final ExpenseRepository expenseRepository;
  final TransactionRepository transactionRepository;

  Future<ProfitReport> execute(DateTimeRange range) async {
    // Get sales profit from transactions
    final salesProfit = await transactionRepository.getProfitForRange(range);

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
    final netProfit = salesProfit - totalExpenses;
    final profitMargin = totalRevenue > 0 ? netProfit / totalRevenue : 0;
    final expenseRatio = totalRevenue > 0 ? totalExpenses / totalRevenue : 0;

    return ProfitReport(...);
  }
}
```

### Sales Report UI Changes

**File**: `lib/features/sales/presentation/screens/reports_screen.dart`

Add to the profit section:

```dart
// After existing profit cards, add:
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
)

// In profit display:
if (_includeExpenses && profitReport != null) {
  Column(
    children: [
      SummaryStatCard(
        title: 'Profit Bersih',
        value: CurrencyFormatter.format(profitReport.netProfit),
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
            Text('Total: ${CurrencyFormatter.format(profitReport.totalExpenses)}'),
            Text('Rasio: ${(profitReport.expenseRatio * 100).toStringAsFixed(1)}% dari pendapatan'),
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
  )
}
```

---

## Dependency Injection

### Add to main.dart

```dart
// Expense Data Source
ProxyProvider<DatabaseHelper, ExpenseLocalDataSourceImpl>(
  update: (_, db, __) => ExpenseLocalDataSourceImpl(databaseHelper: db),
);

// Expense Repository
ProxyProvider<ExpenseLocalDataSourceImpl, ExpenseRepositoryImpl>(
  update: (_, dataSource, __) => ExpenseRepositoryImpl(localDataSource: dataSource),
);

// Expense Use Cases
ProxyProvider<ExpenseRepositoryImpl, AddExpenseUseCase>(
  update: (_, repo, __) => AddExpenseUseCase(repository: repo),
);

ProxyProvider<ExpenseRepositoryImpl, GetExpensesUseCase>(
  update: (_, repo, __) => GetExpensesUseCase(repository: repo),
);

ProxyProvider<ExpenseRepositoryImpl, UpdateExpenseUseCase>(
  update: (_, repo, __) => UpdateExpenseUseCase(repository: repo),
);

ProxyProvider<ExpenseRepositoryImpl, DeleteExpenseUseCase>(
  update: (_, repo, __) => DeleteExpenseUseCase(repository: repo),
);

ProxyProvider<ExpenseRepositoryImpl, GetExpenseSummaryUseCase>(
  update: (_, repo, __) => GetExpenseSummaryUseCase(repository: repo),
);

// New use cases
ProxyProvider<ExpenseRepositoryImpl, GetExpenseCountByCategoryUseCase>(
  update: (_, repo, __) => GetExpenseCountByCategoryUseCase(repository: repo),
);

ProxyProvider2<ExpenseRepositoryImpl, TransactionRepository, GetProfitReportUseCase>(
  update: (_, expenseRepo, transactionRepo, __) => GetProfitReportUseCase(
    expenseRepository: expenseRepo,
    transactionRepository: transactionRepo,
  ),
);

// Expense Controller - Update constructor to accept new use cases
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
);
```

---

## New Files to Create

| File | Purpose |
|------|---------|
| `lib/features/expenses/presentation/screens/expense_screen.dart` | Main tabbed screen |
| `lib/features/expenses/presentation/widgets/expense_form_dialog.dart` | Add/edit expense |
| `lib/features/expenses/presentation/widgets/expense_list_tab.dart` | Expense list with filters |
| `lib/features/expenses/presentation/widgets/expense_summary_tab.dart` | Dashboard with charts |
| `lib/features/expenses/presentation/widgets/expense_categories_tab.dart` | Category list (read-only) |
| `lib/features/expenses/presentation/widgets/expense_filter_bar.dart` | Filter chips and controls |
| `lib/features/expenses/presentation/widgets/expense_card.dart` | Individual expense item |
| `lib/features/expenses/presentation/utils/expense_category_helper.dart` | Color/icon mapping |
| `lib/features/expenses/domain/entities/profit_report.dart` | Profit calculation entity |
| `lib/features/expenses/domain/usecases/get_profit_report_usecase.dart` | Profit calculation |
| `lib/features/expenses/domain/usecases/get_expense_count_by_category_usecase.dart` | Category counts |

---

## Files to Modify

| File | Changes |
|------|---------|
| `lib/features/shared/presentation/drawer_sections.dart` | Add `DrawerExpensesItem` widget |
| `lib/features/shared/presentation/main_navigation.dart` | Add Expenses item to drawer ListView |
| `lib/features/sales/presentation/screens/reports_screen.dart` | Add expense toggle, profit display |
| `lib/main.dart` | Add expense dependency injection chain |
| `lib/features/expenses/presentation/controllers/expense_controller.dart` | Extend with new use cases and filter state |

---

## Design System Compliance

- **Colors**: Use `AppTheme` semantic colors for category coding
- **Spacing**: Material 3 increments (4, 8, 12, 16, 20px)
- **Typography**: `titleMedium`, `bodyMedium`, `labelSmall` per Material 3
- **Borders**: 12px radius for cards, 8px for chips
- **Widgets**: Reuse `ModernButton`, `ModernCard`, `SummaryStatCard`
- **Loading**: `CircularProgressIndicator` for full-screen, `ShimmerLoading` for skeleton
- **Currency**: Use `CurrencyFormatter.format()` utility
- **Charts**: Use `fl_chart` package (already in dependencies)
- **Swipe**: Use `flutter_slidable` package (already in dependencies)
- **Images**: Use `image_picker` package (already in dependencies)

---

## Success Criteria

- [ ] Can add expense with all fields
- [ ] Can edit/delete existing expenses
- [ ] Summary shows correct totals by period
- [ ] Categories display with correct expense counts
- [ ] Receipt photos attach, display, and delete properly
- [ ] Filters work correctly (category, date range)
- [ ] Empty states show appropriate messages
- [ ] Sales report integrates expense data
- [ ] Charts render correctly using fl_chart
- [ ] All error cases handled gracefully
- [ ] Navigation from drawer works correctly
