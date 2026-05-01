# Inventory Enhancement with Stock Management Design

> **Date:** 2026-05-01
> **Status:** Approved Design

---

## Overview

Enhance the inventory management system to support:
1. Unit of measurement selection for all products (pcs, box, kg, liter, dozen, pack, meter, set)
2. Stock adjustment functionality with two modes: Set Quantity and Adjust Stock
3. Stock history tracking with audit trail (who, when, what, why, quantity)
4. Editable item details with all fields
5. Refactor large dialog files by extracting components to keep them maintainable

---

## Architecture

### High-Level Approach

Extend the product dialog structure with three new widget components to keep files under ~400 lines each:

1. **UnitOfMeasurementDropdown** - Reusable dropdown for UOM selection
2. **StockAdjustmentSection** - Toggle between "Set Quantity" and "Adjust Stock" modes
3. **StockHistoryDialog** - Separate dialog showing audit log for a product

### Database Changes

**Products table:**
- Add `unit_of_measurement` column (TEXT, NOT NULL, default 'pcs')

**New stock_adjustments table:**
```sql
CREATE TABLE stock_adjustments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  previous_quantity INTEGER NOT NULL,
  new_quantity INTEGER NOT NULL,
  adjustment_type TEXT NOT NULL, -- 'set', 'purchase', 'sale', 'damage', 'return', 'manual', 'other'
  reason TEXT, -- for 'other' type or custom explanation
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### Why This Architecture

- Each widget has single responsibility and can be tested independently
- Stock adjustment logic isolated from product editing logic
- Reusable components reduce duplication between add/edit dialogs
- Extracting sub-widgets keeps main dialogs focused on orchestration

---

## Data Flow

### Adding/Editing Product Flow

1. User opens Add/Edit Product Dialog
2. All product fields displayed (name, price, costPrice, stock, category, supplier, barcode, unit of measurement)
3. Unit of measurement dropdown (required, defaults to "pcs")
4. Stock adjustment section with toggle:
   - **"Set Quantity" mode:** Input field for new total stock
   - **"Adjust Stock" mode:** Input field for +/- adjustment amount + reason dropdown
5. User fills all fields and submits
6. If "Adjust Stock" mode selected:
   - Stock adjustment recorded to `stock_adjustments` table (who, when, product, change amount, reason)
   - Product stock updated (current stock + adjustment amount)
7. If "Set Quantity" mode or regular edit:
   - Product updated in database with all fields including unit_of_measurement
8. Dialog closes, inventory screen refreshes

### Viewing Stock History Flow

1. User clicks "Stock History" button on product
2. StockHistoryDialog opens showing all adjustments for that product
3. List displays: date/time, adjustment type, amount change, user, custom reason
4. User can close dialog

### Why This Flow

- Clear separation between setting stock (overwrite) and adjusting stock (audit trail)
- History provides accountability for stock changes
- All stock changes are traceable regardless of mode

---

## Component Details

### UnitOfMeasurementDropdown

**Responsibility:** Display dropdown with pre-defined units, handle selection, validation

**Interface:**
```dart
class UnitOfMeasurementDropdown extends StatelessWidget {
  final String? selectedUnit;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  static const List<String> units = [
    'pcs', 'box', 'kg', 'liter', 'dozen', 'pack', 'meter', 'set'
  ];
}
```

**Features:**
- Dropdown with all pre-defined units
- First item "pcs" as default
- Validation: required field, must select one
- Optional: disable dropdown for read-only views

**File:** `lib/features/inventory/presentation/widgets/unit_of_measurement_dropdown.dart` (~60 lines)

---

### StockAdjustmentSection

**Responsibility:** Handle stock adjustment logic, toggle between modes, validate inputs

**Interface:**
```dart
class StockAdjustmentSection extends StatefulWidget {
  final int currentStock;
  final StockAdjustmentMode initialMode;
  final Function({
    required StockAdjustmentMode mode,
    required int quantity,
    String? reason,
    String? customReason,
  }) onAdjust;
}

enum StockAdjustmentMode { setQuantity, adjustStock }
```

**Features:**
- Toggle switch between modes (SegmentedButton or Tab)
- Mode A: "Set Quantity" - text field for new total
- Mode B: "Adjust Stock" - text field for +/- amount + reason dropdown
- Reason dropdown: Purchase, Sale, Damage, Return, Manual Adjustment, Other
- If "Other" selected, show text field for custom reason
- Validation: quantity must be non-negative, reason required if adjust mode
- Disable if read-only

**File:** `lib/features/inventory/presentation/widgets/stock_adjustment_section.dart` (~150 lines)

---

### StockHistoryDialog

**Responsibility:** Display stock adjustment history for a product

**Interface:**
```dart
class StockHistoryDialog extends StatelessWidget {
  final int productId;
  final String productName;
}
```

**Features:**
- Fetch stock adjustments for productId from controller
- Display in ListView with cards: date/time, type icon, amount (+green/-red), reason, user
- Empty state message if no history
- Close button

**File:** `lib/features/inventory/presentation/widgets/stock_history_dialog.dart` (~120 lines)

---

### Updated Product Dialogs

**AddProductDialog:**
- Add `UnitOfMeasurementDropdown` widget
- Add `StockAdjustmentSection` widget (default: setQuantity mode)
- Keep existing fields (name, price, costPrice, category, supplier, barcode, image)
- Total: ~350 lines (manageable)

**EditProductDialog:**
- Add `UnitOfMeasurementDropdown` widget
- Add `StockAdjustmentSection` widget
- Add "View Stock History" button (opens StockHistoryDialog)
- Extract inline category/supplier dialogs to separate files to reduce size
- Total: ~450 lines (manageable after extraction)

---

## Error Handling

### Validation Errors

- Unit of measurement: required field, must be from pre-defined list
- Stock quantity: must be non-negative integer
- Stock adjustment amount: must be integer (positive for add, negative for subtract)
- Adjustment reason: required if "Adjust Stock" mode selected
- Custom reason: required if "Other" selected as reason

### Display Errors

- Inline validation error messages below each field
- Error banner at top of dialog for operation failures (e.g., database error)

### Database Error Handling

- Catch exceptions in controllers (AddProductUseCase, UpdateProductUseCase, StockAdjustmentUseCase)
- Convert to AppException with user-friendly messages
- Display in dialog error banner

### Stock Adjustment Validation

- Check if adjustment would make stock negative → ValidationException
- Check if adjustment amount is zero → ValidationException
- Check if reason missing when required → ValidationException

### Why This Approach

- Prevents invalid stock changes before reaching database
- Clear error feedback helps users fix issues quickly
- Consistent with existing app error handling patterns

---

## Testing Approach

### Unit Tests

- `unit_of_measurement_dropdown_test.dart`: Test dropdown renders, validates, handles selection
- `stock_adjustment_section_test.dart`: Test toggle modes, validation, submission callbacks
- `stock_history_dialog_test.dart`: Test displays adjustments, handles empty state

### Widget Tests

- Test component rendering with different states (normal, disabled, errors)
- Test user interactions (taps, selections, submissions)
- Test validation feedback

### Integration Tests

- Test adding product with unit of measurement
- Test editing product with unit changes
- Test stock adjustment (both set and adjust modes)
- Test stock history recording and retrieval
- Test validation prevents invalid operations

### Database Migration Tests

- Test adding `unit_of_measurement` column to products table
- Test creating `stock_adjustments` table
- Test foreign key constraints
- Test data integrity

### Edge Cases

- Stock adjustment would go negative
- Zero adjustment amount
- Missing required fields
- Custom reason with "Other" selection
- Empty stock history

### Why This Testing Strategy

- Small, focused widgets are easy to test in isolation
- Integration tests verify end-to-end flows work
- Database tests ensure schema changes don't break existing data

---

## Implementation Notes

### Existing Files to Modify

- `lib/features/inventory/domain/entities/product.dart` - Add unitOfMeasurement field
- `lib/features/inventory/data/models/product_model.dart` - Add unitOfMeasurement field with toEntity/fromEntity
- `lib/features/inventory/domain/repositories/product_repository.dart` - Update methods to include unit
- `lib/features/inventory/data/repositories/product_repository_impl.dart` - Update SQL queries
- `lib/features/inventory/presentation/widgets/add_product_dialog.dart` - Add UOM dropdown and stock section
- `lib/features/inventory/presentation/widgets/edit_product_dialog.dart` - Add UOM, stock section, history button
- `lib/services/database/database_schema.dart` - Add unit_of_measurement column, stock_adjustments table
- `lib/core/constants/app_constants.dart` - Increment database version for migration

### New Domain Entities

- `StockAdjustment` entity with fields: id, productId, previousQuantity, newQuantity, adjustmentType, reason, createdBy, createdAt

### New Use Cases

- `AdjustStockUseCase` - Validates and records stock adjustments
- `GetStockHistoryUseCase` - Retrieves stock adjustments for a product

### New Controllers

- `StockAdjustmentController` - Manages stock adjustment operations and history

---

## Success Criteria

- Users can select unit of measurement when adding/editing products
- Stock can be set to a new quantity OR adjusted with +/- amount and reason
- All stock adjustments are recorded in audit log
- Stock history is viewable for any product
- Dialog files remain under 500 lines after refactoring
- All new functionality has unit and integration tests
- Database migration runs without errors
