import 'package:pantry_api/pantry_api.dart';

class PantryException implements Exception {
  final String message;

  const PantryException([this.message = 'An unspecified error occurred']);

  factory PantryException.duplicateItem() {
    return const PantryException('This item already exists in your pantry.');
  }

  factory PantryException.itemNotFound() {
    return const PantryException('Item with the given name not found');
  }

  factory PantryException.notInPantry() {
    return const PantryException('This item is not in your pantry');
  }

  factory PantryException.notInGroceries() {
    return const PantryException('This item is not in your grocery list');
  }
}

abstract class PantryApi {
  const PantryApi();

  /// Provides a [Stream] of all pantry items for a given [user].
  Stream<List<PantryItem>> get pantryItems;

  /// Creates a new empty pantry for a [user]
  Future<void> createNewPantry(String docId);

  /// Opens a stream to listen to updates of a [user]s current [PantryItems]
  Future<void> streamUserPantryItems(String docId);

  /// Add a new [PantryItem] or overwrite an existing [PantryItem]
  /// in a [user]s pantry.
  Future<void> saveItem(String docId, PantryItem item);

  /// Delete a [PantryItem] with the given name
  ///
  /// If no item with that name is found, throws a [PantryException]
  Future<void> deleteItem(String docId, PantryItem item);

  /// Changes the amount remaining on an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  Future<void> changeAmount(String docId, PantryItem item, FoodAmount amount);

  /// Changes the category of the item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  Future<void> changeCategory(
      String docId, PantryItem item, FoodCategory category);

  /// Toggles whether an item is in the grocery list or the pantry
  Future<void> toggleInGroceries(
      String docId, PantryItem item, bool inGroceryList);

  /// Toggles whether an item in the grocery list is checked or not
  ///
  /// Throws a [PantryException] if the item is not in the user's grocery list
  Future<void> toggleChecked(String docId, PantryItem item, bool isChecked);
}
