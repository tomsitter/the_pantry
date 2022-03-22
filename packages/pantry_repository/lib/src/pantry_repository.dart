import 'package:pantry_api/pantry_api.dart';

/// A repository that handles pantry related requests
class PantryRepository {
  final PantryApi _pantryApi;

  const PantryRepository({required PantryApi pantryApi})
      : _pantryApi = pantryApi;

  Stream<List<PantryItem>> getPantryItems() => _pantryApi.getPantryItems();

  /// Fetches all of a [user]s current [PantryItems]
  ///
  /// Creates and returns a new Pantry if user does not yet have one.
  Future<void> fetchPantryItems(String docId) =>
      _pantryApi.fetchPantryItems(docId);

  /// Adds a new [PantryItem] or overwrites an existing one in a [user]s pantry
  Future<void> savePantryItem(String docId, PantryItem item) =>
      _pantryApi.saveItem(docId, item);

  /// Delete a [PantryItem] from a [user]'s pantry
  ///
  /// If an item with the same name as the [PantryItem] does not exist,
  /// throws a [PantryException]
  Future<void> deletePantryItem(String docId, PantryItem item) =>
      _pantryApi.deleteItem(docId, item);

  /// Changes the amount remaining on an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  Future<void> changeAmount(String docId, PantryItem item, FoodAmount amount) =>
      _pantryApi.changeAmount(docId, item, amount);

  /// Changes the category of an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  Future<void> changeCategory(
          String docId, PantryItem item, FoodCategory category) =>
      _pantryApi.changeCategory(docId, item, category);

  /// Toggles whether an item is in the grocery list or the pantry
  Future<void> toggleInGroceries(
          String docId, PantryItem item, bool inGroceryList) =>
      _pantryApi.toggleInGroceries(docId, item, inGroceryList);

  /// Toggles whether an item in the grocery list is checked or not
  ///
  /// Throws a [PantryException] if the item is not in the user's grocery list
  Future<void> toggleChecked(String docId, PantryItem item, bool isChecked) =>
      _pantryApi.toggleChecked(docId, item, isChecked);
}
