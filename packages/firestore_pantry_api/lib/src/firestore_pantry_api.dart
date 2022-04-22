import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantry_api/pantry_api.dart';
import 'package:rxdart/rxdart.dart';

class FirestorePantryApi extends PantryApi {
  final FirebaseFirestore _firestore;

  FirestorePantryApi({required FirebaseFirestore instance, String? docId})
      : _firestore = instance {
    if (docId != null && docId.isNotEmpty) streamUserPantryItems(docId);
  }

  final _pantryItemStreamController =
      BehaviorSubject<List<PantryItem>>.seeded(const []);

  /// Provides a [Stream] of all pantry items.
  @override
  Stream<List<PantryItem>> get pantryItems =>
      _pantryItemStreamController.asBroadcastStream();

  @override
  Future<void> createNewPantry(String docId) async {
    // TODO: implement createNewPantry
    throw UnimplementedError();
    // _firestoreService.createNewPantry(docId);
    // _pantryItemStreamController.add(const []);
  }

  /// Returns a stream of [DocumentSnapshot]s of a user's Pantry stream
  /// Creates a new empty pantry for user if none exists
  Stream<DocumentSnapshot> _streamFromFirestore(String userId) async* {
    if (userId.isNotEmpty) {
      final docReference = _firestore.collection('user_data').doc(userId);

      docReference.get().then((docSnapshot) {
        if (!docSnapshot.exists) {
          docReference.set({'pantry': <String, dynamic>{}}).catchError((error) {
            print('Failed to create a new pantry for user');
          });
          print('Created new pantry for $userId');
        }
      });

      await for (final snapshot in docReference.snapshots()) {
        if (snapshot.data() != null) {
          yield snapshot;
        }
      }
    }
  }

  Future<void> _updateItem(
      String id, Map<String, dynamic> item, String userId) async {
    /// Overwrites an item with the same name property or creates a new item.
    try {
      _firestore
          .collection('user_data')
          .doc(userId)
          .update({'pantry.$id': item[id]});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteItem(String id, String userId) async {
    try {
      _firestore
          .collection('user_data')
          .doc(userId)
          .update({'pantry.$id': FieldValue.delete()});
    } catch (e) {
      print(e);
      return;
    }
  }

  /// Listens to snapshots from the user's pantry. If the snapshot is different
  /// than the current list of [PantryItem]s, then add to the stream.
  @override
  Future<void> streamUserPantryItems(String docId) async {
    await _streamFromFirestore(docId).listen((DocumentSnapshot snapshot) {
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        List<PantryItem> pantryList = data['pantry']
            .entries
            .map<PantryItem>((item) => PantryItem.fromFirestore(item))
            .toList();

        // Only add to stream if the snapshot is different than our current pantry item list
        // or the current pantryList is empty
        if (pantryList.isEmpty ||
            (!ListEquality()
                .equals(pantryList, [..._pantryItemStreamController.value]))) {
          _pantryItemStreamController.add(pantryList);
        }
      }
    });
  }

  /// Add a new [PantryItem] to a [user]'s pantry, or updates an existing
  /// one if item with same [id] exists.
  @override
  Future<void> saveItem(String docId, PantryItem item) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      pantryItems.add(item);
    } else {
      pantryItems[index] = item;
    }
    _pantryItemStreamController.add(pantryItems);
    _updateItem(item.id, item.toJson(), docId);
  }

  /// Deletes a [PantryItem] from a [user]s pantry
  ///
  /// Throws a [PantryException] if the item does not exist
  @override
  Future<void> deleteItem(String docId, PantryItem item) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems.removeAt(index);
      _pantryItemStreamController.add(pantryItems);
      _deleteItem(item.id, docId);
    }
  }

  /// Changes the amount remaining on an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  @override
  Future<void> changeAmount(
      String docId, PantryItem item, FoodAmount amount) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(amount: amount);
      _pantryItemStreamController.add(pantryItems);
      _updateItem(item.id, item.toJson(), docId);
    }
  }

  /// Changes the category on an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  @override
  Future<void> changeCategory(
      String docId, PantryItem item, FoodCategory category) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(category: category);
      _pantryItemStreamController.add(pantryItems);
      _updateItem(item.id, item.toJson(), docId);
    }
  }

  /// Toggles whether an item in the grocery list is checked or not
  ///
  /// Throws a [PantryException] if the item is not in the user's grocery list
  @override
  Future<void> toggleChecked(
      String docId, PantryItem item, bool isChecked) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(isChecked: isChecked);
      _pantryItemStreamController.add(pantryItems);
      _updateItem(item.id, item.toJson(), docId);
    }
  }

  /// Toggles whether an item is in the grocery list or the pantry
  @override
  Future<void> toggleInGroceries(
      String docId, PantryItem item, bool inGroceryList) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(inGroceryList: inGroceryList);
      _pantryItemStreamController.add(pantryItems);
      _updateItem(item.id, item.toJson(), docId);
    }
  }
}
