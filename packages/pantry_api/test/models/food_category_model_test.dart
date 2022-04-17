import 'package:pantry_api/pantry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Food amount model', () {

    // constructor
    FoodCategory createSubject({
      FoodType category = FoodType.pantry
    }) {
      return FoodCategory(
          category
      );
    }

    group('Constructor', () {
      test('Works correctly', () {
        expect(
            createSubject,
            returnsNormally
        );
      });

      test('Supports equality', () {
        expect(
          createSubject(),
          equals(createSubject()),
        );
      });

      test('Props are correct', () {
        expect(
            createSubject().props,
            equals([
              FoodType.pantry
            ])
        );
      });

      test('From string works', () {
        expect(
          FoodCategory.fromString('frozen'),
          equals(
            const FoodCategory(FoodType.frozen),
          )
        );
      });

      test('From string with invalid type throws Food', () {
        expect(
              () => FoodCategory.fromString('invalid type'),
          throwsA(const TypeMatcher<FoodCategoryException>()),
        );
      });
    });

    group('Methods', () {
      test('displayName', () {
        expect(
          createSubject().displayName,
          equals('Pantry')
        );
      });

      test('Sorts alphabetically by display name', () {
        expect(
            [
            FoodCategory(FoodType.frozen),
            FoodCategory(FoodType.pantry),
            FoodCategory(FoodType.baking),
            ]..sort(),
          equals(
              const [
                FoodCategory(FoodType.baking),
                FoodCategory(FoodType.frozen),
                FoodCategory(FoodType.pantry),
              ]
          )
        );
      });
    });

  });



}