import 'package:pantry_api/pantry_api.dart';

class PantryException implements Exception {
  final String message;

  const PantryException([this.message = "An unspecified error occurred"]);

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
  Stream<List<PantryItem>> getPantryItems();

  /// Fetches all of a [user]s current [PantryItems]
  ///
  /// Creates and returns a new Pantry if user does not yet have one.
  Future<void> fetchPantryItems(String docId);

  /// Add a new [PantryItem] to a [user]'s pantry
  ///
  /// Throws a [PantryException] if item with the same name exists
  Future<void> addItem(String docId, PantryItem item);

  /// Overwrite an existing [PantryItem] by name in a [user]s pantry.
  ///
  /// Throws a [PantryException] if item with same name not found.
  Future<void> updateItem(String docId, PantryItem item);

  /// Delete a [PantryItem] with the given name
  ///
  /// If no item with that name is found, throws a [PantryException]
  Future<void> deleteItem(String docId, PantryItem item);

  /// Changes the amount remaining on an item in the user's pantry
  ///
  /// Throws a [PantryException] if item is not in the user's pantry
  Future<void> changeAmount(String docId, PantryItem item, Amount amount);

  /// Toggles whether an item is in the grocery list or the pantry
  Future<void> toggleInGroceries(
      String docId, PantryItem item, bool inGroceryList);

  /// Toggles whether an item in the grocery list is checked or not
  ///
  /// Throws a [PantryException] if the item is not in the user's grocery list
  Future<void> toggleChecked(String docId, PantryItem item, bool isChecked);
}