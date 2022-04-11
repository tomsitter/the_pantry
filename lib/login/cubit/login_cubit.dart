import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:form_inputs/form_inputs.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authRepository;
  LoginCubit(this._authRepository) : super(const LoginState());

  void emailChanged(String value) {
    final email = Email.dirty(value.trim());
    emit(state.copyWith(
        email: email, status: Formz.validate([email, state.password])));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
        password: password, status: Formz.validate([state.email, password])));
  }

  Future<void> loginWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authRepository.loginWithEmailAndPassword(
          email: state.email.value, password: state.password.value);
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on LoginWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authRepository.signInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on LoginWithGoogleFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
