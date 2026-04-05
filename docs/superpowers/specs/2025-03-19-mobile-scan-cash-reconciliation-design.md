# Mobile Scan Mode & Cash Reconciliation Feature Design

**Date:** 2024-03-19
**Status:** Approved (Revised)
**Target:** Mini Market / Grocery POS (Mobile)

---

## Overview

Add mobile-optimized scanning workflow and cash reconciliation features to improve checkout speed and shift closing accuracy for mini market operations.

**Goals:**
1. Fast barcode scanning with one-handed mobile operation
2. Accurate cash reconciliation at shift close
3. Minimal friction during peak hours

**Scope Clarification:**
- Cash counting happens at **shift close only**, not per transaction
- Scan mode uses the existing cart and POS controller (no separate cart)
- Cash counts are stored separately but linked to shifts for audit trail

---

## 1. Scan Mode Screen

### Purpose
Full-screen dedicated scanning interface for rapid product scanning.

### Layout

| Area | Percentage | Description |
|------|------------|-------------|
| Top | 20% | Last scanned product card |
| Middle | 50% | Live camera scanner with detection frame |
| Bottom | 30% | Cart summary + action buttons |

### Components

**Last Scanned Product Card:**
- Large product name
- Price display
- Quantity stepper (+/- buttons)
- Swipe left to remove with undo toast

**Camera Scanner View:**
- Live camera feed
- Green detection frame when barcode identified
- Tap to focus
- Long-press to toggle flash
- Auto-continue after successful scan

**Cart Summary Bar:**
- Running total display
- Item count
- "Hold Order" button (left)
- "Checkout" button (right, primary color)
- "Clear" icon button (top-right)

### Behavior
- Haptic feedback on successful scan
- Product card animates in from top
- Scanner auto-refocuses for next item
- Pull down to minimize (shows cart behind)
- State persists on app background

### Entry Points
1. Floating camera button on POS screen
2. Tap cart header to expand
3. Toggle from existing POS screen

---

## 2. Cash Count Screen

### Purpose
Touch-friendly cash reconciliation interface for shift closing.

### Layout

**Header:**
- Title: "Hitung Uang di Laci"
- Expected amount display

**Main Content:**
2-column grid of bill denomination buttons:
- Each row: [Denomination] [Counter] [+]
- Denominations: 100k, 50k, 20k, 10k, 5k, 2k, 1k, 500, 200, 100

**Bottom Summary Card:**
- Total counted (auto-calculated)
- Expected amount (from shift data)
- Discrepancy (colored: green for positive, red for negative)

**Action Buttons:**
- "Simpan & Tutup" (primary)
- "Batal" (secondary)

### Behavior
- Tap [+] to increment count
- Tap counter to edit via numpad
- Real-time discrepancy calculation
- Color-coded discrepancy display

### Entry Point
- Replaces existing shift close flow
- Triggered from Shift Management → "Tutup Shift"

---

## 3. Data Models

### 3.1 CashCount Entity

```dart
class CashCount {
  final int? id;
  final int shiftId;
  final Map<int, int> billCounts; // denomination value -> count
  final int totalCounted;
  final int expectedAmount;
  final int discrepancy;
  final DateTime countedAt;
  final String countedBy;

  CashCount({
    this.id,
    required this.shiftId,
    required this.billCounts,
    required this.totalCounted,
    required this.expectedAmount,
    required this.discrepancy,
    required this.countedAt,
    required this.countedBy,
  });
}
```

### 3.2 CashDenomination Enum

```dart
enum CashDenomination {
  rupiah100000(100000),
  rupiah50000(50000),
  rupiah20000(20000),
  rupiah10000(10000),
  rupiah5000(5000),
  rupiah2000(2000),
  rupiah1000(1000),
  rupiah500(500),
  rupiah200(200),
  rupiah100(100);

  final int value;
  const CashDenomination(this.value);

  String get display {
    switch (this) {
      case rupiah100000: return '100.000';
      case rupiah50000: return '50.000';
      case rupiah20000: return '20.000';
      case rupiah10000: return '10.000';
      case rupiah5000: return '5.000';
      case rupiah2000: return '2.000';
      case rupiah1000: return '1.000';
      case rupiah500: return '500';
      case rupiah200: return '200';
      case rupiah100: return '100';
    }
  }
}
```

### 3.3 Relationship with Existing Shift Entity

The existing `Shift` entity already has:
- `closingBalance` (single total)
- `discrepancy` getter
- `expectedClosingBalance` getter

**New `CashCount` entity:**
- Stores detailed denomination breakdown (audit trail)
- Linked to shift via `shiftId`
- Does NOT replace existing shift fields
- Used for detailed reporting and reconciliation

### 3.4 Database Changes

**Migration: Version 13 → 14**

```sql
CREATE TABLE cash_counts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shift_id INTEGER NOT NULL,
  denomination INTEGER NOT NULL,
  count INTEGER NOT NULL DEFAULT 0,
  counted_at INTEGER NOT NULL,
  counted_by TEXT NOT NULL,
  FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE
);

CREATE INDEX idx_cash_counts_shift ON cash_counts(shift_id);
CREATE INDEX idx_cash_counts_denomination ON cash_counts(denomination);
```

**Update `AppConstants.databaseVersion` from 13 to 14.**

---

## 4. Navigation Flow

```
POS Screen
    ↓ (tap scan button)
Scan Mode (scanning products)
    ↓ (tap checkout)
Checkout Dialog (payment selection)
    ↓ (select "Tunai")
Cash Count Screen (count bills)
    ↓ (confirm)
Shift Closed → Receipt Option
```

**State Preservation:**
- Scan mode persists on app background
- Cash count saved if user backs out
- Cart maintained in scan mode

**Back Navigation:**
- Scan mode back button: Minimizes to cart view
- Cash count back button: Saves progress, returns to shift management
- Confirmation dialogs for unsaved changes

---

## 5. Error Handling

### Scan Mode
| Scenario | Handling |
|----------|----------|
| Barcode not found | Bottom sheet with quick add form (pre-filled barcode) |
| Camera permission denied | Permission request dialog with explanation |
| Camera unavailable | "Use manual entry" fallback button |
| Network lost | Use cached images, show placeholders |
| Scanning too fast | 500ms debounce between scans |

### Cash Count
| Scenario | Handling |
|----------|----------|
| Count doesn't match expected | Warning + allow proceed |
| Large discrepancy (>10%) | Confirmation requiring manager PIN/note |
| Negative shift close | Require explanation note |
| No cash sales | Skip cash count screen |

---

## 6. Implementation Components

### New Files

**POS Feature:**
- `lib/features/pos/presentation/screens/scan_mode_screen.dart`
- `lib/features/pos/presentation/screens/product_not_found_bottom_sheet.dart`
- `lib/features/pos/presentation/widgets/scan_overlay.dart`
- `lib/features/pos/presentation/widgets/last_scanned_product_card.dart`
- `lib/features/pos/presentation/widgets/cart_summary_bar.dart`

**Shifts Feature:**
- `lib/features/shifts/presentation/screens/cash_count_screen.dart`
- `lib/features/shifts/presentation/widgets/denomination_grid.dart`
- `lib/features/shifts/presentation/widgets/cash_summary_card.dart`

**Core Widgets:**
- `lib/core/widgets/bill_counter_button.dart`

### Modified Files

- `lib/features/pos/presentation/screens/pos_screen.dart` - Add scan mode button
- `lib/features/pos/presentation/controllers/pos_controller.dart` - Add scan mode state
- `lib/features/shifts/presentation/screens/shift_close_screen.dart` - Integrate cash count
- `lib/features/shifts/presentation/controllers/shift_controller.dart` - Add cash count methods
- `lib/services/database/database_helper.dart` - Add cash_counts table

---

## 7. Clean Architecture File Structure

### 7.1 Shifts Feature (Cash Count)

**Domain Layer:**
```
lib/features/shifts/domain/
  entities/
    cash_count.dart
  repositories/
    cash_count_repository.dart (add methods)
  usecases/
    save_cash_count_usecase.dart
    get_cash_count_by_shift_usecase.dart
```

**Data Layer:**
```
lib/features/shifts/data/
  models/
    cash_count_model.dart
  datasources/
    cash_count_local_datasource_impl.dart
  repositories/
    cash_count_repository_impl.dart
```

### 7.2 POS Feature (Scan Mode)

**Scan mode uses existing POS domain entities** - no new domain entities needed.

**Presentation Layer Only:**
```
lib/features/pos/presentation/
  screens/
    scan_mode_screen.dart
    product_not_found_bottom_sheet.dart
  widgets/
    scan_overlay.dart
    last_scanned_product_card.dart
    cart_summary_bar.dart
```

**Controller:**
- Extend existing `POSController` with scan mode state
- No separate controller needed

---

## 8. Provider Dependency Injection

Add to `main.dart` ProxyProvider chains:

### 8.1 For Cash Count (Shifts Feature)

```dart
// After existing shifts providers
ProxyProvider<ShiftRepository, CashCountLocalDataSourceImpl>(
  update: (_, shiftRepo, __) => CashCountLocalDataSourceImpl(
    databaseHelper: shiftRepo.databaseHelper,
  ),
),

ProxyProvider<CashCountLocalDataSourceImpl, CashCountRepositoryImpl>(
  update: (_, dataSource, __) => CashCountRepositoryImpl(
    localDataSource: dataSource,
  ),
),

ProxyProvider<CashCountRepositoryImpl, SaveCashCountUseCase>(
  update: (_, repo, __) => SaveCashCountUseCase(repository: repo),
),

ProxyProvider<CashCountRepositoryImpl, GetCashCountByShiftUseCase>(
  update: (_, repo, __) => GetCashCountByShiftUseCase(repository: repo),
),

// Update ShiftController ProxyProvider to include new use cases
ChangeNotifierProxyProvider8<...> // Increment number based on existing
```

### 8.2 Scan Mode (No new DI needed)

Scan mode state is managed within existing `POSController` - no new providers needed.

---

## 9. Third-Party Packages

### 9.1 Barcode Scanner

**Package:** `mobile_scanner: ^5.0.0`

**Features:**
- Multi-platform (Android/iOS)
- Fast barcode detection
- Front/rear camera support
- Flash control
- Pause/resume scanning

**Permissions:**
- Android: `android.permission.CAMERA`
- iOS: Add `NSCameraUsageDescription` to Info.plist

**Alternative:** If `mobile_scanner` has issues, fallback to `flutter_barcode_scanner`

---

## 10. Testing

### Unit Tests
- CashCount calculation logic
- Denomination counter increments
- Scan mode state transitions

### Integration Tests
- Scan → Add to cart flow
- Cash count → Shift close flow
- Camera permission handling

### Manual Testing Checklist
- [ ] Scan products with real barcode scanner
- [ ] Test on various Android devices
- [ ] Cash counting with different bill combinations
- [ ] App background/foreground during scan
- [ ] Large discrepancy handling
- [ ] Permission denied flows

---

## 11. Success Criteria

1. Cashier can scan 30+ items/minute with scan mode
2. Cash reconciliation takes <2 minutes at shift close
3. Zero data loss on app background/foreground
4. Discrepancy detection accuracy: 100%
