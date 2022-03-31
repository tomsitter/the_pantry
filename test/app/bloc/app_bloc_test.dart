import 'package:authentication_repository/authentication_repository.dart';
import 'package:the_pantry/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('AppBloc', () {
    final user = MockUser();
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(() => authenticationRepository.user).thenAnswer((_) =>
          const Stream.empty());
      when(() => authenticationRepository.currentUser).thenReturn(User.empty);
    });

    test('initial state is unauthenticated when user is empty', () {
      expect(
          AppBloc(authRepository: authenticationRepository).state.status,
          AppStatus.unauthenticated
      );
    });

    group('UserChanged', () {
      blocTest<AppBloc, AppState>(
        'emits authenticated when user is not empty',
        setUp: () {
          when(() => user.isNotEmpty).thenReturn(true);
          when(() => authenticationRepository.user).thenAnswer((_) =>
              Stream.value(user));
        },
        build: () =>
            AppBloc(
              authRepository: authenticationRepository,
            ),
        seed: AppState.unauthenticated,
        expect: () => [AppState.authenticated(user)],
      );

      blocTest<AppBloc, AppState>(
          'emits unauthenticated when user is empty',
          setUp: () {
            when(() => authenticationRepository.user).thenAnswer((_) =>
                Stream.value(User.empty));
          },
          build: () =>
              AppBloc(
                authRepository: authenticationRepository,
              ),
          expect: () => [const AppState.unauthenticated()]
      );
    });

    group('Logout Requested', () {
      blocTest<AppBloc, AppState>(
        'emits unauthenticated when logout requested',
            setUp: () {
          when(() => authenticationRepository.signOut()).thenAnswer((_) async {});
            },
        build: () => AppBloc(authRepository: authenticationRepository),
          act: (bloc) => bloc.add(AppLogoutRequested()),
        verify: (_) {
          verify(() => authenticationRepository.signOut()).called(1);
        },
      );
    });
  });
}