import 'package:authentication_repository/authentication_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/app/app.dart';
import 'package:the_pantry/theme/theme.dart';

import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthenticationRepository extends Mock implements AuthenticationRepository {}
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
      authenticationRepository = MockAuthenticationRepository();
      foodRepository = MockFoodRepository();
      pantryRepository = MockPantryRepository();
      user = MockUser();

      when(() => authenticationRepository.user).thenAnswer(
          (_) => const Stream.empty(),
      );
      when(() => authenticationRepository.currentUser).thenReturn(user);
      when(() => pantryRepository.pantryItems).thenAnswer(
          (_) => const Stream.empty(),
      );
      when(() => pantryRepository.streamUserPantryItems('123')).thenAnswer(
          (invocation) async {},
      );
      when(() => user.isNotEmpty).thenReturn(true);
      when(() => user.isEmpty).thenReturn(false);
      when(() => user.email).thenReturn('test@gmail.com');
      when(() => user.id).thenReturn('123');
    });


    testWidgets('render AppView', (tester) async {
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

    });
}