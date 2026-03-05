# Barcode Scanner Refactoring Plan

## Overview
Move the shared `BarcodeScannerScreen` from `lib/features/pos/` to `lib/core/presentation/widgets/` to follow Clean Architecture principles and make it available as a true shared component.

## Current State Analysis

**Scanner Location**: `lib/features/pos/presentation/screens/barcode_scanner_screen.dart`

**Current Usage**:
1. **POS Feature** (via `MainNavigation`):
   - FAB in bottom navigation (only visible on POS tab)
   - Navigates to scanner → calls `POSScreen.handleBarcodeScanned()`
   - Logic: Lookup product → Add to cart

2. **Inventory Feature** (direct import from POS feature):
   - Small FAB above main "Add Product" button
   - Navigates to scanner → checks for duplicate barcode
   - Logic: Show edit warning OR open add dialog with pre-filled barcode

**Dependencies**:
- `mobile_scanner: ^5.0.0` package
- `flutter/services.dart` (HapticFeedback)
- `core/theme.dart` (AppTheme colors - already shared)

**Problem**: Inventory imports from POS feature (`lib/features/pos/presentation/screens/barcode_scanner_screen.dart`), which violates Clean Architecture's dependency rule (lower-level features shouldn't depend on higher-level features).

## Refactoring Plan

### Phase 1: Create Core Presentation Structure
1. Create `lib/core/presentation/` directory (if not exists)
2. Create `lib/core/presentation/widgets/` subdirectory

### Phase 2: Move Scanner Component
1. Move `barcode_scanner_screen.dart` to `lib/core/presentation/widgets/barcode_scanner_screen.dart`
2. Update imports if needed (keep relative path to `core/theme.dart`)

### Phase 3: Update All Import References
Update imports in the following files:

1. **`lib/features/shared/presentation/main_navigation.dart`** (line 4):
   - From: `../../pos/presentation/screens/barcode_scanner_screen.dart`
   - To: `../../../core/presentation/widgets/barcode_scanner_screen.dart`

2. **`lib/features/inventory/presentation/screens/inventory_screen.dart`** (line 17):
   - From: `../../../pos/presentation/screens/barcode_scanner_screen.dart`
   - To: `../../../../core/presentation/widgets/barcode_scanner_screen.dart`

### Phase 4: Verify & Test
1. Run `flutter analyze` to check for any remaining import issues
2. Run `flutter test` to ensure tests still pass
3. Manually test scanner from:
   - POS screen (main navigation FAB)
   - Inventory screen (scan-to-add FAB)
4. Verify both features process scanned barcodes correctly

## Files to Modify

### Files to Create
- `lib/core/presentation/widgets/barcode_scanner_screen.dart` (moved from POS)

### Files to Update (Imports Only)
- `lib/features/shared/presentation/main_navigation.dart`
- `lib/features/inventory/presentation/screens/inventory_screen.dart`

### Files to Delete
- `lib/features/pos/presentation/screens/barcode_scanner_screen.dart` (after move)

## Benefits

1. **Correct Architecture**: Scanner is now at the core level, not owned by POS
2. **No Cross-Feature Dependencies**: Inventory no longer depends on POS
3. **Reusability**: Any future feature can easily import from core
4. **Single Source of Truth**: One scanner component for the entire app
5. **Easier Maintenance**: Scanner updates happen in one shared location

## No Breaking Changes

- Scanner widget API remains identical (`onScanned` callback)
- Navigation pattern unchanged
- Both features will work exactly as before
- No user-visible changes

## Testing Checklist

- [ ] Scanner opens from POS screen FAB
- [ ] Scanner opens from Inventory screen FAB
- [ ] Flash toggle works
- [ ] Camera flip works
- [ ] Scan again button works
- [ ] POS: Product lookup and add to cart works
- [ ] Inventory: Duplicate barcode detection works
- [ ] Inventory: Pre-filling barcode in add dialog works
- [ ] `flutter analyze` passes with no errors
- [ ] App runs without crashes
