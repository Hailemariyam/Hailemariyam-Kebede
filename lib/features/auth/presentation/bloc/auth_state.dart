part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.pin = '',
    this.pinError,
    this.isPinValid = false,
    this.session,
    this.errorMessage,
  });

  final AuthStatus status;

  /// Current PIN input.
  final String pin;

  /// Inline validation message for the PIN field (null when valid/untouched).
  final String? pinError;

  /// Whether the PIN passes validation — drives the submit button.
  final bool isPinValid;

  /// Set once authentication succeeds.
  final AuthSession? session;

  /// Set on [AuthStatus.failure] — a message safe to show the user.
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    String? pin,
    String? Function()? pinError,
    bool? isPinValid,
    AuthSession? session,
    String? Function()? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      pin: pin ?? this.pin,
      pinError: pinError != null ? pinError() : this.pinError,
      isPinValid: isPinValid ?? this.isPinValid,
      session: session ?? this.session,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, pin, pinError, isPinValid, session, errorMessage];
}
