import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mpesa_lehulum/core/di/injection_container.dart';
import 'package:mpesa_lehulum/core/network/api_client.dart';
import 'package:mpesa_lehulum/core/network/network_info.dart';
import 'package:mpesa_lehulum/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mpesa_lehulum/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mpesa_lehulum/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mpesa_lehulum/features/auth/domain/repositories/auth_repository.dart';
import 'package:mpesa_lehulum/features/auth/domain/usecases/login_usecase.dart';
import 'package:mpesa_lehulum/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mpesa_lehulum/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mpesa_lehulum/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mpesa_lehulum/features/auth/presentation/widgets/pin_input.dart';
import 'package:mpesa_lehulum/features/home/data/datasources/home_local_datasource.dart';
import 'package:mpesa_lehulum/features/home/data/repositories/home_repository_impl.dart';
import 'package:mpesa_lehulum/features/home/domain/repositories/home_repository.dart';
import 'package:mpesa_lehulum/features/home/domain/usecases/get_recent_transactions.dart';
import 'package:mpesa_lehulum/features/home/presentation/bloc/home_bloc.dart';
import 'package:mpesa_lehulum/features/home/presentation/pages/home_page.dart';

const _successBody = {
  'success': true,
  'message': 'Login successful',
  'data': {
    'user': {
      'id': 'USR-10001',
      'name': 'John Doe',
      'phoneNumber': '251911234567',
      'email': 'john.doe@example.com',
      'balance': 1250.5,
      'currency': 'ETB',
    },
    'token': 'mock_access_token_123456',
    'expiresIn': 3600,
  },
};

const _errorBody = {
  'success': false,
  'message': 'User not found',
  'error': {
    'code': 'USER_NOT_FOUND',
    'details': 'No user was found with the provided phone number.',
  },
};

class _AlwaysOnline implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

/// Wire the graph by hand with a mock HTTP client so no real network happens.
Future<void> _register(http.Client client) async {
  await sl.reset();
  sl.registerLazySingleton<ApiClient>(() => ApiClient(client: client));
  sl.registerLazySingleton<NetworkInfo>(_AlwaysOnline.new);
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl.new);
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()));
  sl.registerLazySingleton<HomeLocalDataSource>(HomeLocalDataSourceImpl.new);
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetRecentTransactions(sl()));
  sl.registerFactory(() => HomeBloc(getRecentTransactions: sl()));
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  final fields = find.byType(TextField);
  for (var i = 0; i < pin.length; i++) {
    await tester.enterText(fields.at(i), pin[i]);
    await tester.pump();
  }
}

Future<void> _pumpN(WidgetTester tester, [int n = 10]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  tearDown(sl.reset);

  testWidgets('submit button is disabled until the PIN is complete',
      (tester) async {
    await _register(MockClient((_) async => http.Response('{}', 200)));
    await tester.pumpWidget(const MaterialApp(home: SignInPage()));

    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await _enterPin(tester, '111');
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(3), '1');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });

  testWidgets('valid PIN shows a loader then navigates to the home screen',
      (tester) async {
    String? sentBody;
    final gate = Completer<void>();
    await _register(MockClient((request) async {
      sentBody = request.body;
      await gate.future; // hold the response open so the loader is observable
      return http.Response(jsonEncode(_successBody), 200,
          headers: {'content-type': 'application/json'});
    }));

    await tester.pumpWidget(const MaterialApp(home: SignInPage()));
    await _enterPin(tester, '1111');
    await tester.pump(); // let AuthBloc emit loading
    await tester.pump();

    // Button shows the spinner while the request is in flight.
    expect(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    gate.complete();
    await _pumpN(tester);

    expect(jsonDecode(sentBody!), {'pin': '1111'});
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.textContaining('ETB'), findsWidgets);
  });

  testWidgets('API error surfaces the message and clears the PIN',
      (tester) async {
    await _register(MockClient((_) async => http.Response(
          jsonEncode(_errorBody),
          404,
          headers: {'content-type': 'application/json'},
        )));

    await tester.pumpWidget(const MaterialApp(home: SignInPage()));
    await _enterPin(tester, '0000');
    await _pumpN(tester);

    expect(find.byType(HomePage), findsNothing);
    expect(find.text('User not found'), findsOneWidget);
    for (final f in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(f.controller?.text ?? '', isEmpty);
    }
  });

  testWidgets('network failure shows a connection message', (tester) async {
    await sl.reset();
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(client: MockClient((_) async {
        throw http.ClientException('offline');
      })),
    );
    sl.registerLazySingleton<NetworkInfo>(_AlwaysOnline.new);
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl.new);
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), local: sl(), networkInfo: sl()),
    );
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
    sl.registerFactory(
      () => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()),
    );

    await tester.pumpWidget(const MaterialApp(home: SignInPage()));
    await _enterPin(tester, '1111');
    await _pumpN(tester);

    expect(find.byType(HomePage), findsNothing);
    expect(find.textContaining('connect'), findsOneWidget);
  });

  testWidgets('PinInput.clear empties every box', (tester) async {
    final key = GlobalKey<PinInputState>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PinInput(key: key, onChanged: (_) {}),
      ),
    ));

    await _enterPin(tester, '1234');
    key.currentState!.clear();
    await tester.pump();

    for (final f in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(f.controller?.text ?? '', isEmpty);
    }
  });
}
