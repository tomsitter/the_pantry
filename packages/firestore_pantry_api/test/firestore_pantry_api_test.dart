import 'dart:async';

import 'package:pantry_api/pantry_api.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firestore_pantry_api/firestore_pantry_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// class MockFirestoreService extends Mock implements FirestoreService {}
// class MockPantryApi extends Mock implements PantryApi {}
//
// class FakePantryItem extends Fake implements PantryItem {}
//
// class FakeFoodCategory extends Fake implements FoodCategory {}
//
// class FakeFoodAmount extends Fake implements FoodAmount {}

void main() {
  group('FirestorePantryApi', () {
    final mockDocId = '123';
    final Map<String, Map<String, dynamic>> pantryRaw = {
      'pantry': {
        '1': {
          'name': 'apple',
          'isChecked': false,
          'inGroceryList': true,
          'category': 'produce',
          'amount': 'full',
          'dateAdded': Timestamp(1650566130, 0),
        },
        '2': {
          'name': 'banana',
          'isChecked': false,
          'inGroceryList': false,
          'category': 'produce',
          'amount': 'low',
          'dateAdded': Timestamp(1650566130, 0)
        },
      }
    };

    final List<PantryItem> pantryItems = pantryRaw['pantry']!
        .entries
        .map<PantryItem>((item) => PantryItem.fromFirestore(item))
        .toList();

    group('constructor', () {
      FirestorePantryApi createSubject() =>
          FirestorePantryApi(docId: null, instance: FakeFirebaseFirestore());

      FirestorePantryApi createSubjectWithDocId() => FirestorePantryApi(
          docId: mockDocId, instance: FakeFirebaseFirestore());

      test('works properly with no docId', () {
        expect(createSubject, returnsNormally);
      });

      test('works properly with docId', () {
        expect(createSubjectWithDocId, returnsNormally);
      });
    });

    group('streamUserPantryItems', () {
      late FirestorePantryApi firestorePantryApi;

      setUp(() {
        final fakeFirestore = FakeFirebaseFirestore();
        fakeFirestore.collection('user_data').doc(mockDocId).set(pantryRaw);
        firestorePantryApi = FirestorePantryApi(instance: fakeFirestore);
      });

      test('streams pantry items', () async {
        firestorePantryApi.streamUserPantryItems(mockDocId);
        await expectLater(
            firestorePantryApi.pantryItems, emitsInOrder([[], pantryItems]));
      });
    });

    group('updates items', () {
      late FirestorePantryApi firestorePantryApi;
      late List<PantryItem> items;

      setUp(() async {
        final fakeFirestore = FakeFirebaseFirestore();
        await fakeFirestore
            .collection('user_data')
            .doc(mockDocId)
            .set(pantryRaw);
        firestorePantryApi = FirestorePantryApi(instance: fakeFirestore);
        await firestorePantryApi.streamUserPantryItems(mockDocId);
        items = await firestorePantryApi.pantryItems.firstWhere(
          (event) => event.length > 0,
          orElse: () => [],
        );
      });

      group('saveItem', () {
        test('saves a new pantry item', () async {
          final newItem = PantryItem(name: 'cucumber');
          firestorePantryApi.saveItem(mockDocId, newItem);
          firestorePantryApi.pantryItems.listen(
            expectAsync1(
              (value) => expect(
                value,
                equals(items..add(newItem)),
              ),
            ),
          );
        });

        test('overwrites an existing pantry item', () async {
          final newItem = items[0].copyWith(name: 'cucumber');
          firestorePantryApi.saveItem(mockDocId, newItem);
          firestorePantryApi.pantryItems.listen(
            expectAsync1(
              (value) => expect(
                value,
                equals([newItem, items[1]]),
              ),
            ),
          );
        });
      });

      group('deleteItem', () {
        test('deleteItem works', () {
          firestorePantryApi.deleteItem(mockDocId, items[0]);
          firestorePantryApi.pantryItems.listen(
            expectAsync1(
              (value) => expect(
                value,
                equals([items[1]]),
              ),
            ),
          );
        });

        test('deleteItem throws PantryException if item not found', () async {
          PantryItem newItem = PantryItem(name: 'new item');
          expect(
            firestorePantryApi.deleteItem(mockDocId, newItem),
            throwsA(isA<PantryException>()),
          );
        });
      });

      group('toggleChecked', () {
        test('toggleChecked works', () async {
          PantryItem newItem =
              items[0].copyWith(isChecked: !items[0].isChecked);
          firestorePantryApi.toggleChecked(
              mockDocId, items[0], !items[0].isChecked);
          expect(
            firestorePantryApi.pantryItems,
            emitsThrough([newItem, items[1]]),
          );
        });

        test('toggleChecked throws PantryException if item not found',
            () async {
          PantryItem newItem = PantryItem(name: 'new item');
          expect(
            firestorePantryApi.toggleChecked(mockDocId, newItem, true),
            throwsA(isA<PantryException>()),
          );
        });
      });

      group('toggleInGroceries', () {
        test('toggleInGroceries works', () async {
          PantryItem newItem =
              items[0].copyWith(inGroceryList: !items[0].inGroceryList);
          firestorePantryApi.toggleInGroceries(
              mockDocId, items[0], !items[0].inGroceryList);
          expect(
            firestorePantryApi.pantryItems,
            emitsThrough([newItem, items[1]]),
          );
        });

        test('toggleInGroceries throws PantryException if item not found',
            () async {
          PantryItem newItem = PantryItem(name: 'new item');
          expect(
            firestorePantryApi.toggleInGroceries(mockDocId, newItem, true),
            throwsA(isA<PantryException>()),
          );
        });
      });

      group('changeAmount', () {
        test('changeAmount', () async {
          PantryItem newItem =
              items[0].copyWith(amount: FoodAmount.fromString('empty'));
          firestorePantryApi.changeAmount(
              mockDocId, items[0], FoodAmount.fromString('empty'));
          expect(
            firestorePantryApi.pantryItems,
            emitsThrough([newItem, items[1]]),
          );
        });

        test('changeAmount throws PantryException if item not found', () async {
          PantryItem newItem = PantryItem(name: 'new item');
          expect(
            firestorePantryApi.changeAmount(
                mockDocId, newItem, FoodAmount.full),
            throwsA(isA<PantryException>()),
          );
        });
      });

      group('changeCategory', () {
        test('changeCategory', () async {
          PantryItem newItem =
              items[0].copyWith(category: FoodCategory.fromString('frozen'));
          firestorePantryApi.changeCategory(
              mockDocId, items[0], FoodCategory.fromString('frozen'));
          expect(
            firestorePantryApi.pantryItems,
            emitsThrough([newItem, items[1]]),
          );
        });

        test('changeCategory throws PantryException if item not found',
            () async {
          PantryItem newItem = PantryItem(name: 'new item');
          expect(
            firestorePantryApi.changeCategory(
                mockDocId, newItem, FoodCategory.uncategorized),
            throwsA(isA<PantryException>()),
          );
        });
      });
    });
  });
}
