import 'package:pantry_api/pantry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Food amount model', () {
    // constructor
    FoodAmount createSubject({Amount amount = Amount.full}) {
      return FoodAmount(amount);
    }

    group('Constructor', () {
      test('Works correctly', () {
        expect(createSubject, returnsNormally);
      });

      test('Supports equality', () {
        expect(
          createSubject(),
          equals(createSubject()),
        );
      });

      test('Props are correct', () {
        expect(createSubject().props, equals([Amount.full]));
      });

      test('fromString works correct', () {
        expect(
          FoodAmount.fromString('empty'),
          equals(const FoodAmount(Amount.empty)),
        );
      });

      test('fromString with invalid string throws FoodAmountException', () {
        expect(
          () => FoodAmount.fromString('invalid type'),
          throwsA(const TypeMatcher<FoodAmountException>()),
        );
      });
    });

    group('Methods', () {
      test('Display name is correct', () {
        expect(createSubject().displayName, equals('Full'));
      });
    });
  });
}
