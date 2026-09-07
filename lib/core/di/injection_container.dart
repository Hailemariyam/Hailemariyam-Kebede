import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_recent_transactions.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

/// Service locator. Composition root wiring the dependency graph so features
/// depend on abstractions, never on concrete construction.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<http.Client>(http.Client.new);

  // ── Core ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ApiClient>(() => ApiClient(client: sl()));
  sl.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);

  // ── Auth: data ────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl.new);
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl(),
      local: sl(),
      networkInfo: sl(),
    ),
  );

  // ── Auth: domain ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ── Auth: presentation ────────────────────────────────────────────────
  sl.registerFactory(
    () => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()),
  );

  // ── Home: data ────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeLocalDataSource>(HomeLocalDataSourceImpl.new);
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));

  // ── Home: domain ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetRecentTransactions(sl()));

  // ── Home: presentation ────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(getRecentTransactions: sl()));
}
