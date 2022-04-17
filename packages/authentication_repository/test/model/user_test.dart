import 'package:authentication_repository/authentication_repository.dart';
import 'package:test/test.dart';

void main() {
  group('User', () {
    const mockId = 'mock-id';
    const mockEmail = 'mock-email';

    test('Props set correctly', () {
      expect(
          const User(
            id: mockId,
            email: mockEmail,
            isEmailVerified: true,
          ).props,
          equals([mockId, mockEmail, true]));
    });

    test('User is not empty', () {
      const user = User(id: mockId, email: mockEmail, isEmailVerified: false);
      expect(
        user.isNotEmpty,
        isTrue,
      );

      expect(
        user.isEmpty,
        isFalse,
      );
    });

    test('Empty user is empty', () {
      User emptyUser = User.empty;

      expect(
          emptyUser.props,
          equals([
            '', // no id
            '', // no email
            false // email not verified
          ]));

      expect(emptyUser.isEmpty, equals(true));
      expect(emptyUser.isNotEmpty, equals(false));
    });
  });
}
