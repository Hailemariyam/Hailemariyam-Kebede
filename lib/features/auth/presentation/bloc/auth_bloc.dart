import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Orchestrates the sign-in flow: live PIN validation, the login request,
/// loading/error/success states, and sign-out.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _login = loginUseCase,
        _logout = logoutUseCase,
        super(const AuthState()) {
    on<AuthPinChanged>(_onPinChanged);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _login;
  final LogoutUseCase _logout;

  void _onPinChanged(AuthPinChanged event, Emitter<AuthState> emit) {
    final pin = event.pin;
    // Only surface an inline error once the field is full but still invalid
    // (e.g. non-digits); stay quiet while the user is mid-entry.
    final showError = pin.length >= Validators.pinLength;
    emit(state.copyWith(
      status: AuthStatus.initial,
      pin: pin,
      isPinValid: Validators.isPinComplete(pin),
      pinError: () => showError ? Validators.pin(pin) : null,
      errorMessage: () => null,
    ));
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final validationError = Validators.pin(state.pin);
    if (validationError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        pinError: () => validationError,
        errorMessage: () => validationError,
      ));
      return;
    }

    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: () => null,
    ));

    final result = await _login(LoginParams(pin: state.pin));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        // Reset the PIN entry so the user re-enters after a failed attempt.
        pin: '',
        isPinValid: false,
        pinError: () => null,
        errorMessage: () => failure.message,
      )),
      (session) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        pinError: () => null,
        errorMessage: () => null,
      )),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    emit(const AuthState());
  }
}
