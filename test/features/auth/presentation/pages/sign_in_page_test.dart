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
import 'package:mpesa_lehulum/features/auth/presentation/widgets/number_keypad.dart';
import 'package:mpesa_lehulum/features/auth/presentation/widgets/pin_dots.dart';
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

/// Tap keypad digits by their visible label.
Future<void> _tapDigits(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.text(d));
    await tester.pump();
  }
}

Future<void> _pumpN(WidgetTester tester, [int n = 10]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// The sign-in screen (header + keypad + button + footer) is tall; give the
/// test surface enough height that nothing scrolls out of the hit-test region.
Future<void> _pumpSignIn(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: SignInPage()));
}

void main() {
  tearDown(sl.reset);

  testWidgets('renders the custom keypad and identity header', (tester) async {
    await _register(MockClient((_) async => http.Response('{}', 200)));
    await _pumpSignIn(tester);

    expect(find.text('Enter Your M-PESA PIN'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    // Keypad digits 0-9 present.
    for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
      expect(find.text(d), findsOneWidget);
    }
    // Footer links.
    expect(find.text('Forgot PIN'), findsOneWidget);
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
  });

  testWidgets('Continue is disabled until 4 digits are entered', (tester) async {
    await _register(MockClient((_) async => http.Response('{}', 200)));
    await _pumpSignIn(tester);

    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await _tapDigits(tester, '111');
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await _tapDigits(tester, '1');
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });

  testWidgets('backspace key removes the last digit', (tester) async {
    await _register(MockClient((_) async => http.Response('{}', 200)));
    await _pumpSignIn(tester);

    await _tapDigits(tester, '1234');
    expect(tester.widget<PinDots>(find.byType(PinDots)).filledCount, 4);

    // The only icon inside the keypad is its backspace action.
    final backspace = find.descendant(
      of: find.byType(NumberKeypad),
      matching: find.byType(Icon),
    );
    await tester.tap(backspace);
    await tester.pump();

    expect(tester.widget<PinDots>(find.byType(PinDots)).filledCount, 3);
  });

  testWidgets('valid PIN shows the loader then navigates home', (tester) async {
    String? sentBody;
    final gate = Completer<void>();
    await _register(MockClient((request) async {
      sentBody = request.body;
      await gate.future;
      return http.Response(jsonEncode(_successBody), 200,
          headers: {'content-type': 'application/json'});
    }));

    await _pumpSignIn(tester);
    await _tapDigits(tester, '1111');
    await _tapDigits(tester, ''); // no-op pump
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();

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
  });

  testWidgets('API error surfaces the message and resets the PIN',
      (tester) async {
    await _register(MockClient((_) async => http.Response(
          jsonEncode(_errorBody),
          404,
          headers: {'content-type': 'application/json'},
        )));

    await _pumpSignIn(tester);
    await _tapDigits(tester, '0000');
    await tester.tap(find.text('Continue'));
    await _pumpN(tester);

    expect(find.byType(HomePage), findsNothing);
    expect(find.text('User not found'), findsOneWidget);
    expect(tester.widget<PinDots>(find.byType(PinDots)).filledCount, 0);
  });

  testWidgets('network failure shows a connection message', (tester) async {
    await _register(MockClient((_) async {
      throw http.ClientException('offline');
    }));

    await _pumpSignIn(tester);
    await _tapDigits(tester, '1111');
    await tester.tap(find.text('Continue'));
    await _pumpN(tester);

    expect(find.byType(HomePage), findsNothing);
    expect(find.textContaining('connect'), findsOneWidget);
  });
}
