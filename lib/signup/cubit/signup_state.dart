part of 'signup_cubit.dart';

class SignupState extends Equatable {
  final FormzStatus status;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final TOUCheckbox agreeToTOU;
  final String? errorMessage;

  const SignupState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.agreeToTOU = const TOUCheckbox.pure(),
    this.errorMessage,
  });

  SignupState copyWith({
    FormzStatus? status,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    TOUCheckbox? agreeToTOU,
    String? errorMessage,
  }) {
    return SignupState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmedPassword: confirmedPassword ?? this.confirmedPassword,
        agreeToTOU: agreeToTOU ?? this.agreeToTOU,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [status, email, password, confirmedPassword, agreeToTOU];
}
