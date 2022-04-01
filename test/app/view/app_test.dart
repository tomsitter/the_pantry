import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/app/app.dart';
import 'package:the_pantry/login/login.dart';
import 'package:the_pantry/home/home.dart';

import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockFoodRepository extends Mock implements FoodRepository {}

class MockPantryRepository extends Mock implements PantryRepository {}

class MockUser extends Mock implements User {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

void main() {
  group('App', () {
    late AuthenticationRepository authenticationRepository;
    late FoodRepository foodRepository;
    late PantryRepository pantryRepository;
    late User user;

    setUp(() {
      user = MockUser();
      authenticationRepository = MockAuthenticationRepository();
      foodRepository = MockFoodRepository();
      pantryRepository = MockPantryRepository();

      /// Mock an authenticated user
      when(() => user.isNotEmpty).thenReturn(true);
      when(() => user.isEmpty).thenReturn(false);
      // when(() => user.email).thenReturn('test@gmail.com');
      when(() => user.id).thenReturn('123');
      when(() => authenticationRepository.user).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => authenticationRepository.currentUser).thenReturn(user);

      // Mock a pantry for the authenticated user
      when(() => pantryRepository.pantryItems).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => pantryRepository.streamUserPantryItems('123')).thenAnswer(
        (invocation) async {},
      );
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(
          authenticationRepository: authenticationRepository,
          foodRepository: foodRepository,
          pantryRepository: pantryRepository,
        ),
      );
      await tester.pump();
      expect(find.byType(AppView), findsOneWidget);
    });

    group('AppView', () {
      late AuthenticationRepository authenticationRepository;
      late PantryRepository pantryRepository;
      late FoodRepository foodRepository;
      late AppBloc appBloc;

      setUp(() {
        authenticationRepository = MockAuthenticationRepository();
        pantryRepository = MockPantryRepository();
        foodRepository = MockFoodRepository();
        appBloc = MockAppBloc();
      });

      testWidgets('Navigates to login screen when user is unauthenticated',
          (tester) async {
        when(() => appBloc.state).thenReturn(const AppState.unauthenticated());

        await tester.pumpWidget(MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: authenticationRepository,
            ),
            RepositoryProvider.value(
              value: foodRepository,
            ),
            RepositoryProvider.value(
              value: pantryRepository,
            )
          ],
          child: BlocProvider.value(
              value: appBloc,
              child: const MaterialApp(
                home: AppView(),
              )),
        ));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('Navigates to home screen when user is authenticated',
          (tester) async {
        final user = MockUser();
        when(() => user.id).thenReturn('123');
        when(() => appBloc.state).thenReturn(AppState.authenticated(user));
        when(() => authenticationRepository.user).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => authenticationRepository.currentUser).thenReturn(user);

        // Mock a pantry for the authenticated user with no items
        when(() => pantryRepository.pantryItems).thenAnswer(
          (_) => Stream.value([]),
        );
        when(() => pantryRepository.streamUserPantryItems('123')).thenAnswer(
          (invocation) async {},
        );

        await tester.pumpWidget(MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: authenticationRepository,
            ),
            RepositoryProvider.value(
              value: foodRepository,
            ),
            RepositoryProvider.value(
              value: pantryRepository,
            )
          ],
          child: BlocProvider.value(
              value: appBloc,
              child: const MaterialApp(
                home: AppView(),
              )),
        ));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}
