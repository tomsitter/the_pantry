import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantry_api/pantry_api.dart';
import 'package:rxdart/rxdart.dart';
import 'firestore_service.dart';

class FirestorePantryApi extends PantryApi {
  final FirestoreService _firestoreService;

  FirestorePantryApi({required FirebaseFirestore instance, String? docId})
      : _firestoreService = FirestoreService(firestore: instance) {
    if (docId != null) _init(docId);
  }

  void _init(String docId) async {
    print("In init");
    final data = await _firestoreService.fetchPantryItems(docId);
    if (data != null) {
      List<PantryItem> pantryList = data['pantry']
          .entries
          .map<PantryItem>((item) => PantryItem.fromJson(item))
          .toList();
      _pantryItemStreamController.add(pantryList);
    } else {
      _firestoreService.createNewPantry(docId);
      _pantryItemStreamController.add(const []);
    }
  }

  final _pantryItemStreamController =
      BehaviorSubject<List<PantryItem>>.seeded(const []);

  Future<void> fetchPantryItems(String docId) async {
    print("in fetch");
    final data = await _firestoreService.fetchPantryItems(docId);
    if (data != null) {
      List<PantryItem> pantryList = data['pantry']
          .entries
          .map<PantryItem>((item) => PantryItem.fromJson(item))
          .toList();
      _pantryItemStreamController.add(pantryList);
    } else {
      _firestoreService.createNewPantry(docId);
      _pantryItemStreamController.add(const []);
    }
  }

  /// Provides a [Stream] of all pantry items.
  @override
  Stream<List<PantryItem>> getPantryItems() =>
      _pantryItemStreamController.asBroadcastStream();

  /// Add a new [PantryItem] to a [user]'s pantry
  ///
  /// Throws a [PantryException] if item with the same name exists
  @override
  Future<void> addItem(String docId, PantryItem item) {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.name == item.name);
    if (index >= 0) {
      throw PantryException.duplicateItem();
    } else {
      pantryItems.add(item);
      _pantryItemStreamController.add(pantryItems);
      return _firestoreService.updateItem(item.name, item.toJson(), docId);
    }
  }

  /// Deletes a [PantryItem] from a [user]s pantry
  ///
  /// Throws a [PantryException] if the item does not exist
  @override
  Future<void> deleteItem(String docId, PantryItem item) async {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.name == item.name);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems.removeAt(index);
      _pantryItemStreamController.add(pantryItems);
      return _firestoreService.deleteItem(item.name, docId);
    }
  }

  /// Changes the amount remaining on an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  @override
  Future<void> changeAmount(String docId, PantryItem item, Amount amount) {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.name == item.name);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(amount: amount);
      _pantryItemStreamController.add(pantryItems);
      return _firestoreService.updateItem(item.name, item.toJson(), docId);
    }
  }

  /// Toggles whether an item in the grocery list is checked or not
  ///
  /// Throws a [PantryException] if the item is not in the user's grocery list
  @override
  Future<void> toggleChecked(String docId, PantryItem item, bool isChecked) {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.name == item.name);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(isChecked: isChecked);
      _pantryItemStreamController.add(pantryItems);
      return _firestoreService.updateItem(item.name, item.toJson(), docId);
    }
  }

  /// Toggles whether an item is in the grocery list or the pantry
  @override
  Future<void> toggleInGroceries(
      String docId, PantryItem item, bool inGroceryList) {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.name == item.name);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item.copyWith(inGroceryList: inGroceryList);
      _pantryItemStreamController.add(pantryItems);
      return _firestoreService.updateItem(item.name, item.toJson(), docId);
    }
  }

  @override
  Future<void> updateItem(String docId, PantryItem item) {
    final pantryItems = [..._pantryItemStreamController.value];
    final index = pantryItems.indexWhere((i) => i.name == item.name);
    if (index < 0) {
      throw PantryException.itemNotFound();
    } else {
      pantryItems[index] = item;
      _pantryItemStreamController.add(pantryItems);
      return _firestoreService.updateItem(item.name, item.toJson(), docId);
    }
  }
}
