import 'package:authentication_repository/authentication_repository.dart';
import 'package:the_pantry/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

void main() {
  group('AppState', () {
    test('has correct status', () {
      const state = AppState.unauthenticated();
      expect(state.status, AppStatus.unauthenticated);
      expect(state.user, User.empty);
    });

    test('has correct status', () {
      final user = MockUser();
      final state = AppState.authenticated(user);
      expect(state.status, AppStatus.authenticated);
      expect(state.user, user);
    });
  });
}