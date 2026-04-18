import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core dependency
import 'package:simple_pos/core/database/database_helper.dart';

// Shifts Data Layer
import 'package:simple_pos/features/shifts/data/datasources/shift_local_datasource_impl.dart';
import 'package:simple_pos/features/shifts/data/datasources/cash_count_local_datasource_impl.dart';
import 'package:simple_pos/features/shifts/data/repositories/shift_repository_impl.dart';
import 'package:simple_pos/features/shifts/data/repositories/cash_count_repository_impl.dart';

// Shifts Domain Layer (Use Cases)
import 'package:simple_pos/features/shifts/domain/usecases/open_shift_usecase.dart';
import 'package:simple_pos/features/shifts/domain/usecases/close_shift_usecase.dart';
import 'package:simple_pos/features/shifts/domain/usecases/get_current_shift_usecase.dart';
import 'package:simple_pos/features/shifts/domain/usecases/get_shifts_usecase.dart';
import 'package:simple_pos/features/shifts/domain/usecases/update_shift_totals_usecase.dart';
import 'package:simple_pos/features/shifts/domain/usecases/save_cash_count_usecase.dart';
import 'package:simple_pos/features/shifts/domain/usecases/get_cash_count_by_shift_usecase.dart';

// Shifts Presentation Layer (Controller)
import 'package:simple_pos/features/shifts/presentation/controllers/shift_controller.dart';

/// Shifts feature providers
///
/// Manages all dependencies for shift management:
/// - Shift operations (open, close, get current, get history)
/// - Shift totals tracking
/// - Cash count management
List<SingleChildWidget> createShiftProviders() {
  return [
    // Shift data sources
    ProxyProvider<DatabaseHelper, ShiftLocalDataSourceImpl>(
      update: (_, db, _) => ShiftLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, CashCountLocalDataSourceImpl>(
      update: (_, db, _) => CashCountLocalDataSourceImpl(databaseHelper: db),
    ),

    // Shift repositories
    ProxyProvider<ShiftLocalDataSourceImpl, ShiftRepositoryImpl>(
      update: (_, dataSource, _) =>
          ShiftRepositoryImpl(localDataSource: dataSource),
    ),
    ProxyProvider<CashCountLocalDataSourceImpl, CashCountRepositoryImpl>(
      update: (_, dataSource, _) =>
          CashCountRepositoryImpl(localDataSource: dataSource),
    ),

    // Shift use cases
    ProxyProvider<ShiftRepositoryImpl, OpenShiftUseCase>(
      update: (_, repo, _) => OpenShiftUseCase(shiftRepository: repo),
    ),
    ProxyProvider<ShiftRepositoryImpl, CloseShiftUseCase>(
      update: (_, repo, _) => CloseShiftUseCase(shiftRepository: repo),
    ),
    ProxyProvider<ShiftRepositoryImpl, GetCurrentShiftUseCase>(
      update: (_, repo, _) => GetCurrentShiftUseCase(shiftRepository: repo),
    ),
    ProxyProvider<ShiftRepositoryImpl, GetShiftsUseCase>(
      update: (_, repo, _) => GetShiftsUseCase(shiftRepository: repo),
    ),
    ProxyProvider<ShiftRepositoryImpl, UpdateShiftTotalsUseCase>(
      update: (_, repo, _) => UpdateShiftTotalsUseCase(shiftRepository: repo),
    ),
    ProxyProvider<CashCountRepositoryImpl, SaveCashCountUseCase>(
      update: (_, repo, _) => SaveCashCountUseCase(cashCountRepository: repo),
    ),
    ProxyProvider<CashCountRepositoryImpl, GetCashCountByShiftUseCase>(
      update: (_, repo, _) =>
          GetCashCountByShiftUseCase(cashCountRepository: repo),
    ),

    // Shift controller
    ChangeNotifierProvider<ShiftController>(
      create: (context) => ShiftController(
        openShiftUseCase: context.read(),
        closeShiftUseCase: context.read(),
        getCurrentShiftUseCase: context.read(),
        getShiftsUseCase: context.read(),
        updateShiftTotalsUseCase: context.read(),
        saveCashCountUseCase: context.read(),
        getCashCountByShiftUseCase: context.read(),
      ),
    ),
  ];
}
