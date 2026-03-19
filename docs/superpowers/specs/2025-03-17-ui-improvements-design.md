# UI Improvements Design

**Date**: 2025-03-17
**Feature**: Comprehensive UI/UX Enhancements Across All Screens
**Status**: Design Approved

---

## Overview

Create a consistent, polished UI experience across all 7 screens (POS, Inventory, Sales Reports, Settings, Expenses, Suppliers, History) with reusable widgets and patterns. Follows existing codebase conventions and AppTheme system.

---

## 1. Enhanced Empty States

**File**: `lib/core/widgets/animated_empty_state.dart`

### Add Static Factory Methods

```dart
class AnimatedEmptyState extends StatelessWidget {
  // Existing constructor remains unchanged

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
}
```

---

## 2. Contextual Error Display

**New file**: `lib/core/widgets/contextual_error_display.dart`

### Error Type System

```dart
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
  });

  // Auto-detect from AppException
  // Note: Only detects existing AppException subtypes
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
}
```

### Error Specifications

| Type | Icon | Color | Action | Detected From | Default Message |
|------|------|-------|--------|---------------|-----------------|
| validation | `error_outline` | error | Fix | ValidationException, ConflictException, InsufficientStockException, EmptyCartException | "Periksa input Anda" |
| notFound | `search_off` | info | Back | NotFoundException | "Data tidak ditemukan" |
| database | `storage` | error | Retry | DatabaseException | "Terjadi kesalahan database" |
| unknown | `error` | error | Retry | (catch-all) | "Terjadi kesalahan" |

---

## 3. Form Validation Widget

**New file**: `lib/core/widgets/validated_text_field.dart`

### Widget Implementation

```dart
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
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}
```

### Built-in Validators

```dart
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

**Features**:
- Real-time validation with optional debouncing (default 300ms, set to 0 for immediate)
- Visual error state (red border, shake animation)
- Success state (green checkmark icon)
- Helper text shows errors when invalid
- Accessible error announcements

**Note**: For immediate feedback, set `debounceMs: 0`. For search/filter fields, debouncing is recommended.

---

## 4. Search Results State

**New file**: `lib/core/widgets/search_results_state.dart`

### Widget Implementation

```dart
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
  });
}
```

**Usage**: This is a header widget that wraps the results content. It displays the search summary and wraps the child results list below.

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ "12 hasil untuk 'kopi'"              [Clear Filters]        │
│ Active: Drinks, In Stock (when filters active)             │
├─────────────────────────────────────────────────────────────┤
│ Results list...                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Success Toast Service

**New file**: `lib/core/services/success_toast_service.dart`

### Service Implementation

```dart
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

### Usage

```dart
// Direct access
SuccessToastService.instance.saved(context, 'Produk');

// Via extension method (optional)
context.showSuccess('Data berhasil disimpan');
```

---

## 6. Loading States

**New file**: `lib/core/widgets/loading_overlay.dart`

### Loading Overlay

```dart
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingOverlay({
    this.message,
    this.isFullScreen = true,
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

### List Item Shimmer (Optional Helper)

**Note**: `ShimmerLoading` already exists. This is an optional convenience wrapper.

```dart
class ListItemShimmer extends StatelessWidget {
  final int itemCount;

  const ListItemShimmer({this.itemCount = 5});

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

---

## 7. Micro-interactions

**File to modify**: `lib/core/utils/haptic_helper.dart`

### Enhanced Haptic Helper

```dart
class HapticHelper {
  static void success() => HapticFeedback.mediumImpact();
  static void error() => HapticFeedback.heavyImpact();
  static void warning() => HapticFeedback.lightImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void notification() => HapticFeedback.notification(HapticFeedbackType.success);
}
```

### Usage Guidelines

| Action | Haptic |
|--------|--------|
| Button press | `selection()` |
| Form submit success | `success()` |
| Validation error | `error()` |
| Delete confirmation | `warning()` |
| Task complete | `notification()` |

### Animation Enhancements

- **Staggered list entry**: Use existing `StaggerDelay` utility
- **Button press**: Scale animation (0.95 → 1.0, 100ms)
- **Page transition**: Fade in (150ms)
- **Dialog**: Scale + fade (200ms)

---

## 8. Screen-by-Screen Application

### POS Screen (`lib/features/pos/presentation/screens/pos_screen.dart`)

| Component | Widget/Pattern |
|-----------|----------------|
| Empty cart | `AnimatedEmptyState.noTransactions()` |
| Search no results | `AnimatedEmptyState.searchNoResults(query)` |
| Loading checkout | `LoadingOverlay(message: 'Memproses pembayaran...')` |
| Success | `SuccessToastService.instance.added(context, 'Transaksi')` |
| Form error | `ContextualErrorDisplay.auto()` |

### Inventory Screen (`lib/features/inventory/presentation/screens/inventory_screen.dart`)

| Component | Widget/Pattern |
|-----------|----------------|
| Empty products | `AnimatedEmptyState.noProducts(onAction: openAddDialog)` |
| Search state | `SearchResultsState` with count and filters |
| Add/edit form | `ValidatedTextField` with validators |
| Loading | `ListItemShimmer` on initial load |
| Success | Toast on add/edit/delete |

### Sales Reports Screen (`lib/features/sales/presentation/screens/reports_screen.dart`)

| Component | Widget/Pattern |
|-----------|----------------|
| Empty data | `AnimatedEmptyState.noTransactions()` |
| Loading report | `ListItemShimmer` while generating |
| Load error | `ContextualErrorDisplay.auto(error: e, onRetry: load)` |

### Settings Screen (`lib/features/settings/presentation/screens/settings_screen.dart`)

| Component | Widget/Pattern |
|-----------|----------------|
| All form fields | `ValidatedTextField` with appropriate validators |
| Save success | `SuccessToastService.instance.saved(context)` |
| Validation errors | Inline with red borders |

### Expense Screen (see Expenses UI design spec)

| Component | Widget/Pattern |
|-----------|----------------|
| Empty | `AnimatedEmptyState.noExpenses()` |
| Form | `ValidatedTextField` for amount/description |
| Success | Toast on add/delete |

### Supplier Screen

| Component | Widget/Pattern |
|-----------|----------------|
| Empty | `AnimatedEmptyState.noSuppliers()` |
| Form | `ValidatedTextField` for name, contact, phone |
| Success | Toast on add/edit/delete |

### History/Transactions Screen

| Component | Widget/Pattern |
|-----------|----------------|
| Empty | `AnimatedEmptyState.noTransactions()` |
| Search | `SearchResultsState` with filters |
| Loading | `ListItemShimmer` |

---

## New Files to Create

| File | Purpose |
|------|---------|
| `lib/core/widgets/contextual_error_display.dart` | Error display by type |
| `lib/core/widgets/validated_text_field.dart` | Input validation widget |
| `lib/core/widgets/search_results_state.dart` | Search UX component |
| `lib/core/services/success_toast_service.dart` | Success notification service |
| `lib/core/widgets/loading_overlay.dart` | Loading overlay with message support |
| `lib/core/widgets/list_item_shimmer.dart` | Optional shimmer list helper |

---

## Files to Modify

| File | Changes |
|------|---------|
| `lib/core/widgets/animated_empty_state.dart` | Add 7 preset factory methods (noProducts, noTransactions, noExpenses, noSuppliers, noCategories, searchNoResults, noNetwork) |
| `lib/core/utils/haptic_helper.dart` | Methods already exist, just add documentation comments |

---

## Accessibility Considerations

All widgets should include proper accessibility support:

- **Empty states**: Add `Semantics(label: title, value: subtitle)` for screen readers
- **Validation errors**: Use `Semantics(label: 'Error: $errorMessage')` for announcements
- **Error display**: Announce error type and suggested action
- **Success toasts**: SnackBars are automatically announced by screen readers
- **Form fields**: Use `InputDecoration.labelText` and `errorText` properly
- **Loading states**: Add `Semantics(label: 'Loading', value: message)` for overlay

---

## Design System Compliance

- **Colors**: All use `AppTheme` semantic colors
- **Spacing**: Material 3 increments (4, 8, 12, 16, 20px)
- **Typography**: `titleMedium`, `bodyMedium`, `labelSmall` per Material 3
- **Borders**: 12px radius for cards, 8px for chips
- **Success color**: `AppTheme.successColor` (#10B981 green)
- **Error color**: `AppTheme.errorColor` (#EF4444 red)
- **Warning color**: `AppTheme.warningColor` (#F59E0B amber)

---

## Success Criteria

### Core Widgets
- [ ] All 7 empty state presets render correctly with proper icons and messages
- [ ] ContextualErrorDisplay.auto() detects all AppException subtypes
- [ ] ValidatedTextField shows real-time validation with configurable debounce
- [ ] SearchResultsState displays count, query, and filter chips correctly
- [ ] SuccessToastService shows branded toasts with AppTheme.successColor
- [ ] LoadingOverlay is theme-aware (dark/light mode compatible)

### Screen Applications
- [ ] POS Screen: Uses empty states for cart, loading for checkout
- [ ] Inventory Screen: Uses empty states, search results, validated forms
- [ ] Sales Reports: Uses empty states, loading shimmer
- [ ] Settings: Uses validated text fields, success toasts
- [ ] Expense Screen: Uses empty states, validated forms
- [ ] Supplier Screen: Uses empty states, validated forms
- [ ] History Screen: Uses empty states, search results

### Quality
- [ ] All new widgets have proper accessibility (Semantics labels)
- [ ] Haptic feedback triggered on key interactions
- [ ] Animations are smooth (60fps target)
- [ ] Dark mode compatible for all new components
