part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class Authenticated extends AuthState {
  final User user;

  Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

// If any error occurs the state is changed to AuthError.
class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
  @override
  List<Object?> get props => [error];
}

// class AuthState extends Equatable {
//   final AuthStatus status;
//   final User? user;
//
//   const AuthState._({this.status = AuthStatus.unknown, this.user});
//
//   const AuthState.unknown() : this._();
//
//   const AuthState.authenticated({required User user})
//       : this._(status: AuthStatus.authenticated, user: user);
//
//   const AuthState.unauthenticated()
//       : this._(status: AuthStatus.unauthenticated);
//
//   @override
//   List<Object?> get props => [status, user];
// }
