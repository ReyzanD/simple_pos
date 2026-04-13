# Codebase Chunking & Refactoring Design

**Date:** 2026-04-14
**Status:** Approved
**Type:** Code Organization Refactoring

## Overview

Comprehensive refactoring to break down large files into smaller, maintainable units. The goal is to improve debugging ease, maintainability, and enable parallel development while keeping the application functional throughout the process.

## Problem Statement

The current codebase has several files that exceed 1,000-2,700 lines, making debugging difficult and code hard to navigate:

- `backup_screen.dart` (2,743 lines) - Contains 15+ widget classes
- `sales_report_screen.dart` (2,323 lines)
- `add_product_dialog.dart` (1,722 lines)
- `database_helper.dart` (1,642 lines)
- `analytics_screen.dart` (1,534 lines)
- `pos_screen.dart` (1,385 lines)
- `drawer_sections.dart` (1,153 lines)
- `main.dart` (975 lines) - Massive Provider dependency injection setup

## Solution: Surgical Extraction Method

Extract and reorganize code without changing logic flow. Create feature-based provider groups and extract widgets into separate files while maintaining full application functionality.

## Target Architecture

### File Structure

```
lib/
├── core/
│   ├── providers/                    # NEW: Core provider orchestrators
│   │   ├── core_providers.dart       # Theme, database, etc.
│   │   └── provider_groups.dart      # Re-export groups for main.dart
│   └── ...
├── features/
│   ├── backup/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── backup_screen.dart         # ~300 lines (was 2743)
│   │   │   └── widgets/                       # NEW
│   │   │       ├── backup_storage_status.dart # Extract: _StorageStatusWidget
│   │   │       ├── backup_progress_bar.dart   # Extract: _StorageProgressBar
│   │   │       ├── backup_list_item.dart      # Extract: _BackupListItem
│   │   │       ├── backup_create_dialog.dart  # Extract: _CreateBackupDialog
│   │   │       ├── backup_restore_dialog.dart # Extract: _RestoreDialog
│   │   │       ├── backup_delete_dialog.dart  # Extract: _DeleteBackupDialog
│   │   │       └── backup_schedule_dialog.dart # Extract: _ScheduleBackupDialog
│   │   └── domain/
│   │       └── providers/                      # NEW
│   │           └── backup_providers.dart       # Backup-specific providers
│   ├── sales/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── sales_report_screen.dart   # ~400 lines (was 2323)
│   │   │   └── widgets/                       # NEW
│   │   │       ├── report_summary_cards.dart
│   │   │       ├── report_chart_section.dart
│   │   │       └── report_transaction_list.dart
│   │   └── domain/
│   │       └── providers/
│   │           └── sales_providers.dart
│   ├── pos/
│   │   └── domain/
│   │       └── providers/
│   │           └── pos_providers.dart
│   ├── inventory/
│   │   ├── presentation/
│   │   │   ├── widgets/
│   │   │   │   ├── product_form_fields.dart    # NEW
│   │   │   │   └── variant_configurator.dart   # Already separate
│   │   └── domain/
│   │       └── providers/
│   │           └── inventory_providers.dart
│   └── [other features follow same pattern]
└── main.dart                                  # ~150 lines (was 975)
```

## Extraction Rules

### When to Extract a Widget

Extract a widget when it:
- Is >100 lines
- Is used in multiple places
- Has complex state (StatefulWidgets with multiple methods)
- Represents a distinct UI component

### Naming Convention

```dart
// Before: _StorageStatusWidget (private, in backup_screen.dart)
// After: BackupStorageStatusWidget (public, in backup_storage_status.dart)

// File: backup_storage_status.dart
class BackupStorageStatusWidget extends StatefulWidget {
  // ... widget code
}

// In backup_screen.dart:
import 'widgets/backup_storage_status.dart';

// Use as:
BackupStorageStatusWidget(controller: controller),
```

### State Management

- Keep stateful widgets stateful (don't convert to stateless)
- Preserve all lifecycle methods
- Maintain callback signatures exactly
- Keep animations and controllers

### Dependencies

- Copy all imports from original file
- Add missing imports as needed
- Keep relative imports: `import '../../domain/entities/backup.dart';`

## Provider Reorganization

### Current Problem

main.dart has 975 lines of repeated ProxyProvider chains:
```dart
ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
  update: (_, db, __) => ProductLocalDataSourceImpl(databaseHelper: db),
),
ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
  update: (_, dataSource, __) => ProductRepositoryImpl(localDataSource: dataSource),
),
// ... repeated 50+ times
```

### Solution: Feature-Based Provider Groups

Create provider group files for each feature:

**Core Providers (`lib/core/providers/core_providers.dart`)**
```dart
List<SingleChildWidget> createCoreProviders() {
  return [
    Provider<DatabaseHelper>(
      create: (_) => DatabaseHelper.instance,
    ),
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController(),
    ),
  ];
}
```

**Feature Providers (e.g., `lib/features/backup/domain/providers/backup_providers.dart`)**
```dart
List<SingleChildWidget> createBackupProviders() {
  return [
    ProxyProvider<DatabaseHelper, BackupLocalDataSourceImpl>(
      update: (_, db, __) => BackupLocalDataSourceImpl(databaseHelper: db),
    ),
    ChangeNotifierProxyProvider2<...>(
      update: (_, repo, ...) => BackupController(...),
    ),
  ];
}
```

### New main.dart Structure

```dart
void main() {
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...createCoreProviders(),
        ...createInventoryProviders(),
        ...createPOSProviders(),
        ...createSalesProviders(),
        ...createBackupProviders(),
        ...createExpenseProviders(),
        ...createUserProviders(),
        ...createSettingsProviders(),
        ...createShiftProviders(),
      ],
      child: MaterialApp(...),
    );
  }
}
```

## Import Organization Standard

Organize imports in this order in every file:

```dart
// 1. Flutter & Dart core
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Project core (theme, utils, widgets)
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';

// 3. Feature domain (entities, repositories, use cases)
import '../../domain/entities/backup.dart';

// 4. Feature data (models, data sources)
import '../../data/models/backup_model.dart';

// 5. Feature controllers & presentation
import '../controllers/backup_controller.dart';
```

## File Header Standard

Every widget file gets a documentation header:

```dart
/// BackupStorageStatusWidget
///
/// **Purpose:** Displays storage usage statistics for backup functionality
///
/// **Used by:** BackupScreen
///
/// **State:** StatefulWidget (manages storage calculation animation)
///
/// **Dependencies:** BackupController
library;

import 'package:flutter/material.dart';

class BackupStorageStatusWidget extends StatefulWidget {
  // ...
}
```

## Specific Extraction Plans

### backup_screen.dart (2,743 → ~300 lines)

Extract these widgets:
1. `_StorageStatusWidget` → `BackupStorageStatusWidget`
2. `_StorageProgressBar` → `BackupStorageProgressBar`
3. `_StorageDetailsDialog` → `BackupStorageDetailsDialog`
4. `_DetailRow` → `BackupDetailRow`
5. `_StorageStat` → `BackupStorageStat`
6. `_BackupListItem` → `BackupListItem`
7. `_CreateBackupDialog` → `BackupCreateDialog`
8. `_RestoreDialog` → `BackupRestoreDialog`
9. `_DeleteBackupDialog` → `BackupDeleteDialog`
10. `_ScheduleBackupDialog` → `BackupScheduleDialog`

### sales_report_screen.dart (2,323 → ~400 lines)

Extract into:
1. `ReportSummaryCards` - KPI stats at top
2. `ReportChartSection` - Graphs and visualizations
3. `ReportTransactionList` - Transaction history
4. `ReportFilterDialog` - Filter options

### add_product_dialog.dart (1,722 → ~600 lines)

Split into:
1. `ProductFormFields` - Reusable form field components
2. Keep `AddProductDialog` as orchestrator (but much smaller)

### drawer_sections.dart (1,153 → ~200 lines)

Extract each section into its own file:
1. `DrawerCategoryChips`
2. `DrawerStoreStats`
3. `DrawerLowStockItem`
4. `DrawerDiscountItem`
5. `DrawerBackupItem`
6. `DrawerExpensesItem`
7. `DrawerShiftsItem`
8. `DrawerUsersItem`
9. `DrawerAnalyticsItem`
10. `DrawerThemeToggle`
11. `DrawerRecentProducts`
12. `DrawerAppInfo`

## Execution Order

### Phase 1: Foundation (15 minutes)

1. Create folder structure
2. Create provider group stubs
3. **VERIFY:** App still runs

### Phase 2: Core Providers (30 minutes)

1. Move DatabaseHelper, ThemeController, AuthController to `core_providers.dart`
2. Update main.dart to use `createCoreProviders()`
3. **VERIFY:** App launches, login works

### Phase 3: Feature Providers (2-3 hours)

Migrate one feature at a time in this order:
1. Inventory (most critical)
2. POS (second most critical)
3. Sales (reporting)
4. Backup
5. Expenses
6. Users
7. Settings
8. Shifts

**For each feature:**
- Copy providers to feature_providers.dart
- Update main.dart
- **VERIFY:** Run app, test feature functionality

### Phase 4: Widget Extraction (3-4 hours)

Extract widgets one file at a time in this order:
1. `backup_screen.dart` (biggest win)
2. `sales_report_screen.dart`
3. `add_product_dialog.dart`
4. `drawer_sections.dart`
5. `pos_screen.dart`

**For each widget:**
1. Create new widget file
2. Copy widget class, fix imports
3. Update original file to import new widget
4. **VERIFY:** Hot reload works, widget renders correctly

## Safety Measures

### After Each File Change

```bash
# Hot reload test
flutter run # then press 'r'

# If hot reload fails, full restart
flutter run # fresh start

# Quick smoke test
- App launches
- No red errors
- Can navigate to modified screen
- Widget renders without errors
```

### Git Strategy

- Commit after each successful extraction
- Use descriptive messages: "Extract BackupStorageStatusWidget from backup_screen.dart"
- If something breaks, `git reset --hard HEAD^` and retry

### Rollback Plan

- Keep original code commented out for first extraction in each file
- Remove comments only after verification
- If extraction fails, revert immediately and analyze why

## Success Metrics

### File Size Reduction

- ✅ main.dart: 975 → ~150 lines (85% reduction)
- ✅ backup_screen.dart: 2,743 → ~300 lines (89% reduction)
- ✅ sales_report_screen.dart: 2,323 → ~400 lines (83% reduction)
- ✅ add_product_dialog.dart: 1,722 → ~600 lines (65% reduction)
- ✅ drawer_sections.dart: 1,153 → ~200 lines (83% reduction)
- ✅ All other files: <500 lines

### Architectural Improvements

- ✅ No file exceeds 500 lines (except database_helper.dart)
- ✅ Every widget has a clear, single responsibility
- ✅ Providers organized by feature
- ✅ Easy to locate any piece of code
- ✅ Can add/remove features without touching other features

### Maintainability Gains

- ✅ Debugging: Errors point to specific, small files
- ✅ Testing: Can test widgets in isolation
- ✅ Code review: Changes are scoped to clear files
- ✅ Onboarding: New developers can understand structure quickly

## Final Statistics

- **New widget files:** ~40-50 new widget files
- **New provider files:** 9 provider group files
- **Modified screen files:** ~10 screen files reduced
- **Total new files:** ~50-60 files
- **Total lines of code:** Similar (just reorganized)

## Post-Refactoring Verification

After completion, verify:
1. ✅ App launches without errors
2. ✅ All features work: POS, Inventory, Sales, Backup, Expenses, Settings, Users
3. ✅ Hot reload works smoothly
4. ✅ No console errors or warnings
5. ✅ All imports resolve correctly
6. ✅ Git history shows clean progression

## Migration Notes

This refactoring maintains 100% functional compatibility. No business logic changes, only code organization. All existing tests should pass without modification.
