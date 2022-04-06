import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:form_inputs/form_inputs.dart';

part 'signup_state.dart';

class SignUpCubit extends Cubit<SignupState> {
  final AuthenticationRepository _authRepository;

  SignUpCubit(this._authRepository) : super(const SignupState());

  bool get touChecked => state.agreeToTOU.value;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        status: Formz.validate(
            [email, state.password, state.confirmedPassword, state.agreeToTOU]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        status: Formz.validate(
            [state.email, password, state.confirmedPassword, state.agreeToTOU]),
      ),
    );
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      value: value,
      password: state.password.value,
    );
    emit(
      state.copyWith(
        confirmedPassword: confirmedPassword,
        status: Formz.validate(
            [state.email, state.password, confirmedPassword, state.agreeToTOU]),
      ),
    );
  }

  void agreeToTOUChanged(bool value) {
    final agreeToTOU = TOUCheckbox.dirty(value);
    emit(
      state.copyWith(
        agreeToTOU: agreeToTOU,
        status: Formz.validate(
            [state.email, state.password, state.confirmedPassword, agreeToTOU]),
      ),
    );
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authRepository.signUp(
          email: state.email.value, password: state.password.value);
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
