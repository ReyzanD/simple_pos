# Stock Adjustment Dependencies

StockAdjustmentController is now available and can be imported from `features/shared/presentation/providers.dart`.

## Current Status
- **Import added**: `import '../../inventory/presentation/controllers/stock_adjustment_controller.dart';` added to providers.dart (line 112)
- **Provider chain**: Not wired up in main.dart (uses ProviderScope with MainNavigation as root)
- **Availability**: Screens can import and use StockAdjustmentController from providers.dart

## Integration Steps
To use StockAdjustment functionality in screens:

1. **Add provider to ProviderScope**:
   ```dart
   ProviderScope(
     child: YourScreen(
       // Your screen needs to be a ConsumerStatefulWidget
       // Then inside your screen's build method:
       final controller = ref.read(stockAdjustmentControllerProvider);
   ),
   )
   ```

2. **Create stockAdjustmentControllerProvider**:
   ```dart
   final stockAdjustmentControllerProvider = ChangeNotifierProvider((ref) {
     return StockAdjustmentController(
       adjustStockUseCase: ref.watch(adjustStockUseCaseProvider),
       getStockHistoryUseCase: ref.watch(getStockHistoryUseCaseProvider),
     );
   });
   ```

3. **Provide necessary use cases**:
   In your screen, also add these providers:
   ```dart
   ChangeNotifierProvider<AdjustStockUseCase>((ref) => AdjustStockUseCase(
     repository: ref.watch(stockAdjustmentRepositoryProvider),
   ));
   
   ChangeNotifierProvider<GetStockHistoryUseCase>((ref) => GetStockHistoryUseCase(
     repository: ref.watch(stockAdjustmentRepositoryProvider),
   ));
   ```

## Note
The full provider wiring as described in plan (Task 19) would require significant refactoring of current ProviderScope architecture. The current approach allows screens to access StockAdjustmentController by importing it from providers.dart, but doesn't provide the convenience of a centralized provider.
