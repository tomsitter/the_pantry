import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:pantry_api/pantry_api.dart';

class MockPantryApi extends Mock implements PantryApi {}

class FakePantryItem extends Fake implements PantryItem {}

class FakeFoodCategory extends Fake implements FoodCategory {}

class FakeFoodAmount extends Fake implements FoodAmount {}

void main() {
  group('Constructor', () {
    late PantryApi api;

    const mockDocId = '123';
    final pantryItems = [
      PantryItem(name: 'apple'),
      PantryItem(name: 'banana'),
      PantryItem(name: 'cucumber'),
    ];

    setUpAll(() {
      registerFallbackValue(FakePantryItem());
      registerFallbackValue(FakeFoodCategory());
      registerFallbackValue(FakeFoodAmount());
    });

    setUp(() {
      api = MockPantryApi();
      when(() => api.pantryItems).thenAnswer((_) => Stream.value(pantryItems));
      when(() => api.createNewPantry(any())).thenAnswer((_) async {});
      when(() => api.streamUserPantryItems(any())).thenAnswer((_) async {});
      when(() => api.saveItem(any(), any())).thenAnswer((_) async {});
      when(() => api.deleteItem(any(), any())).thenAnswer((_) async {});
      when(() => api.changeCategory(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => api.changeAmount(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => api.toggleInGroceries(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => api.toggleChecked(any(), any(), any()))
          .thenAnswer((_) async {});
    });

    PantryRepository createSubject() => PantryRepository(pantryApi: api);

    group('constructor', () {
      test('works properly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });
    });

    group('get pantry items', () {
      test('makes correct api request', () {
        expect(
          createSubject().pantryItems,
          isNot(throwsA(anything)),
        );

        verify(() => api.pantryItems).called(1);
      });

      test('returns stream of pantry items', () {
        expect(createSubject().pantryItems, emits(pantryItems));
      });
    });

    group('save pantry item', () {
      test('makes correct api request', () {
        final newPantryItem = PantryItem(
          name: 'test item',
          isChecked: false,
          inGroceryList: true,
        );

        expect(
          createSubject().savePantryItem(mockDocId, newPantryItem),
          completes,
        );

        verify(() => api.saveItem(mockDocId, newPantryItem)).called(1);
      });
    });

    group('delete pantry item', () {
      test('makes correct api request', () {
        expect(
          createSubject().deletePantryItem(mockDocId, pantryItems[0]),
          completes,
        );

        verify(() => api.deleteItem(mockDocId, pantryItems[0])).called(1);
      });
    });

    group('change pantry item category', () {
      test('makes correct api request', () {
        expect(
          createSubject().changeCategory(
              mockDocId, pantryItems[0], FoodCategory.uncategorized),
          completes,
        );

        verify(() => api.changeCategory(
            mockDocId, pantryItems[0], FoodCategory.uncategorized)).called(1);
      });
    });

    group('change pantry item amount', () {
      test('makes correct api request', () {
        expect(
          createSubject()
              .changeAmount(mockDocId, pantryItems[0], FoodAmount.full),
          completes,
        );

        verify(() =>
                api.changeAmount(mockDocId, pantryItems[0], FoodAmount.full))
            .called(1);
      });
    });

    group('toggle pantry item in groceries', () {
      test('makes correct api request', () {
        expect(
          createSubject().toggleInGroceries(mockDocId, pantryItems[0], true),
          completes,
        );

        verify(() => api.toggleInGroceries(mockDocId, pantryItems[0], true))
            .called(1);
      });
    });

    group('toggle pantry item checked', () {
      test('makes correct api request', () {
        expect(
          createSubject().toggleChecked(mockDocId, pantryItems[0], true),
          completes,
        );

        verify(() => api.toggleChecked(mockDocId, pantryItems[0], true))
            .called(1);
      });
    });
  });
}
// constructor works properly

// fetch
// makes correct api request
// returns stream of current pantry items

// save
// makes correct api request

// delete
// makes correct api request

// clear complete
//
