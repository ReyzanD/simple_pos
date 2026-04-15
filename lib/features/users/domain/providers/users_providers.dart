import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/user_local_datasource_impl.dart';
import '../../data/datasources/user_session_local_datasource_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/user_session_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../presentation/controllers/auth_controller.dart';

List<SingleChildWidget> createUserProviders() {
  return [
    // --- DATA LAYER ---
    ProxyProvider<DatabaseHelper, UserLocalDataSourceImpl>(
      update: (_, db, __) => UserLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, UserSessionLocalDataSourceImpl>(
      update: (_, db, __) => UserSessionLocalDataSourceImpl(databaseHelper: db),
    ),

    // --- REPOSITORY LAYER ---
    ProxyProvider<UserLocalDataSourceImpl, UserRepositoryImpl>(
      update: (_, ds, __) => UserRepositoryImpl(localDataSource: ds),
    ),
    ProxyProvider<UserSessionLocalDataSourceImpl, UserSessionRepositoryImpl>(
      update: (_, ds, __) => UserSessionRepositoryImpl(localDataSource: ds),
    ),

    // --- DOMAIN LAYER ---
    ProxyProvider<UserRepositoryImpl, LoginUseCase>(
      update: (_, repo, __) => LoginUseCase(repo),
    ),
    ProxyProvider<UserRepositoryImpl, GetUsersUseCase>(
      update: (_, repo, __) => GetUsersUseCase(repo),
    ),
    ProxyProvider<UserRepositoryImpl, CreateUserUseCase>(
      update: (_, repo, __) => CreateUserUseCase(repo),
    ),
    ProxyProvider<UserRepositoryImpl, UpdateUserUseCase>(
      update: (_, repo, __) => UpdateUserUseCase(repo),
    ),
    ProxyProvider<UserRepositoryImpl, DeleteUserUseCase>(
      update: (_, repo, __) => DeleteUserUseCase(repo),
    ),
    ProxyProvider<UserRepositoryImpl, GetCurrentUserUseCase>(
      update: (_, repo, __) => GetCurrentUserUseCase(repo),
    ),

    // --- PRESENTATION LAYER ---
    ChangeNotifierProvider<AuthController>(
      create: (context) => AuthController(
        loginUseCase: context.read(),
        getUsersUseCase: context.read(),
        createUserUseCase: context.read(),
        updateUserUseCase: context.read(),
        deleteUserUseCase: context.read(),
        getCurrentUserUseCase: context.read(),
      ),
    ),
  ];
}
