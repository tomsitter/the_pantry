part of 'login_cubit.dart';

class LoginState extends Equatable {
  final FormzStatus status;
  final Email email;
  final Password password;
  final String? errorMessage;

  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage,
  });

  LoginState copyWith({
    FormzStatus? status,
    Email? email,
    Password? password,
    String? errorMessage,
  }) {
    return LoginState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object> get props => [status, email, password];
}
