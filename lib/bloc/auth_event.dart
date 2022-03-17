part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested(this.email, this.password);
}

class GoogleSignInRequested extends AuthEvent {
  final String email;
  final String password;

  GoogleSignInRequested(this.email, this.password);
}

class SignOutRequested extends AuthEvent {}

// class AuthUserChanged extends AuthEvent {
//   final User user;
//
//   const AuthUserChanged({required this.user});
//
//   @override
//   List<Object> get props => [];
// }
