part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// The PIN input changed — revalidate and update the button/error state.
class AuthPinChanged extends AuthEvent {
  const AuthPinChanged(this.pin);

  final String pin;

  @override
  List<Object?> get props => [pin];
}

/// The user asked to sign in with the current PIN.
class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted();
}

/// The user asked to sign out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
