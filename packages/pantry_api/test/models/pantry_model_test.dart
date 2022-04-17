// ignore_for_file: avoid_redundant_argument_values
import 'package:test/test.dart';
import 'package:pantry_api/pantry_api.dart';

void main() {
  group('Pantry', () {
    const String dateAddedString = '2022-01-02 13:30:00.000';
    DateTime dateAdded = DateTime.parse(dateAddedString);

    PantryItem createSubject(
        {String? id = '1',
        String name = 'name',
        bool isChecked = true,
        bool inGroceryList = true,
        FoodAmount amount = FoodAmount.full,
        FoodCategory category = FoodCategory.uncategorized,
        String dateAdded = dateAddedString}) {
      return PantryItem(
        id: id,
        name: name,
        isChecked: isChecked,
        inGroceryList: inGroceryList,
        amount: amount,
        category: category,
        dateAdded: DateTime.parse(dateAdded),
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });

      // test('throws AssertionError when id is empty', () {
      //   expect(
      //     () => createSubject(dateAdded, id: ''),
      //     throwsA(isA<AssertionError>()),
      //   );
      // });

      test('sets id if not provided', () {
        expect(
          createSubject(id: null).id,
          isNotEmpty,
        );
      });
    });

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      expect(
        createSubject().props,
        equals([
          '1', // id
          'name', // title
          true, // isChecked
          true, // inGroceryList
          FoodAmount.full,
          FoodCategory.uncategorized,
          DateTime.parse(dateAddedString),
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if not arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            id: null,
            name: null,
            isChecked: null,
            inGroceryList: null,
            amount: null,
            category: null,
            dateAdded: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
              id: '2',
              name: 'new name',
              isChecked: false,
              inGroceryList: false,
              amount: FoodAmount(Amount.empty),
              category: FoodCategory(FoodType.dairy),
              dateAdded: DateTime(2020, 1, 1, 12, 00)),
          equals(
            createSubject(
              id: '2',
              name: 'new name',
              isChecked: false,
              inGroceryList: false,
              amount: FoodAmount(Amount.empty),
              category: FoodCategory(FoodType.dairy),
              dateAdded: '2020-01-01 12:00:00.000',
            ),
          ),
        );
      });
    });

    group('fromJson', () {
      test('works correctly', () {
        expect(
          PantryItem.fromJson(const <String, dynamic>{
            'id': '1',
            'name': 'name',
            'isChecked': true,
            'inGroceryList': true,
            'category': 'uncategorized',
            'amount': 'full',
            'dateAdded': '2022-01-02 13:30:00.000',
          }),
          equals(createSubject()),
        );
      });
    });

    group('toJson', () {
      test('works correctly', () {
        expect(
          createSubject().toJson(),
          equals(<String, dynamic>{
            '1': {
              'name': 'name',
              'isChecked': true,
              'inGroceryList': true,
              'category': 'uncategorized',
              'amount': 'full',
              'dateAdded': dateAdded,
            }
          }),
        );
      });
    });

    group('Methods', () {
      late PantryItem first, second, third, fourth;

      setUp(() {
        first = PantryItem(name: 'aaa', category: const FoodCategory(FoodType.dairy));
        second = PantryItem(name: 'bbb', category: const FoodCategory(FoodType.dairy));
        third = PantryItem(name: 'ccc', category: const FoodCategory(FoodType.dairy));
        fourth = PantryItem(name: 'aaa', category: const FoodCategory(FoodType.pantry));
      });

      test('Sorts by category then name alphabetically', () {
        expect(
            [fourth,second,third,first]..sort(),
            equals([first,second,third,fourth]),
        );
      });
    });
  });
}
