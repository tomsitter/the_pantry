import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:the_pantry/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  // Create a new bloc with an instance of the AuthRepository,
  // subscribe for changed to authenticated user and emit event when changed
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(Unauthenticated()) {
    on<SignInRequested>((event, emit) async {
      print("Sign in requested, emitting AuthLoading");
      emit(AuthLoading());
      await _authRepository
          .signIn(email: event.email, password: event.password)
          .then((result) {
        if (result == "success") {
          print("awaited SignIn, got $result, emitting authenticated");
          var user = _authRepository.currentUser;
          if (user != null) {
            emit(Authenticated(user: user));
          } else {
            emit(AuthError("Authenticated but can't find current user."));
          }
        } else {
          print("awaited SignIn, got $result, emitting autherror");
          emit(AuthError(result));
        }
      }).catchError((e) {
        print("Caught error ${e.toString()}, emitting unauth and autherror");
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      });
    });

    on<SignUpRequested>((event, emit) async {
      await _authRepository
          .signUp(email: event.email, password: event.password)
          .then((result) {
        if (result == "success") {
          print("awaited SignUp, got $result, emitting authenticated");
          var user = _authRepository.currentUser;
          if (user != null) {
            emit(Authenticated(user: user));
          } else {
            emit(AuthError("Authenticated but can't find current user."));
          }
        } else {
          print("awaited SignUp, got $result, emitting autherror");
          emit(AuthError(result));
        }
      }).catchError((e) {
        print("Caught error ${e.toString()}, emitting unauth and autherror");
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      });
    });

    on<GoogleSignInRequested>((event, emit) async {
      await _authRepository
          .signInWithGoogle(email: event.email, password: event.password)
          .then((result) {
        if (result == "success") {
          print(
              "awaited GoogleSignInRequested, got $result, emitting authenticated");
          var user = _authRepository.currentUser;
          if (user != null) {
            emit(Authenticated(user: user));
          } else {
            emit(AuthError("Authenticated but can't find current user."));
          }
        } else {
          print(
              "awaited GoogleSignInRequested, got $result, emitting autherror");
          emit(AuthError(result));
        }
      }).catchError((e) {
        print("Caught error ${e.toString()}, emitting unauth and autherror");
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      });
    });

    // When User Presses the SignOut Button, we will send the SignOutRequested Event to the AuthBloc to handle it and emit the UnAuthenticated State
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }

  // Stream<AuthState> mapEventToState(
  //   AuthEvent event,
  // ) async* {
  //   if (event is AuthUserChanged) {
  //     yield* _mapAuthUserChangedToState(event);
  //   }
  // }
  //
  // Stream<AuthState> _mapAuthUserChangedToState(AuthUserChanged event) async* {
  //   yield AuthState.authenticated(user: event.user);
  // }
  //
  // @override
  // Future<void> close() {
  //   _userSubscription?.cancel();
  //   return super.close();
  // }
}
