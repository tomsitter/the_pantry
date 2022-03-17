import 'package:the_pantry/data/repositories/auth_repository.dart';
import 'package:the_pantry/data/services/firestore_service.dart';

import '../models/pantry_model.dart';

class Repository {
  final FirestoreService db;
  final AuthRepository auth;

  Repository({required this.db, required this.auth});

  Future<PantryList> fetchPantryList() async {
    final user = auth.currentUser;

    if (user != null) {
      final data = await db.fetchPantryItems(user);
      if (data != null) {
        return PantryList.fromJson(data);
      } else {
        final newData = await db.createNewPantry(user);
        if (newData != null) return PantryList.fromJson(newData);
      }
    }

    print('Could not retrieve or create new pantry');
    return PantryList(items: <PantryItem>[PantryItem(name: 'test')]);
  }

  Future<bool> toggleChecked(PantryItem item, bool isChecked) async {
    final user = auth.currentUser;

    if (user != null) {
      final newItem = item.copyWith(isChecked: isChecked);
      return await db.updateItem(newItem.name, newItem.toJson(), user);
    }
    return false;
  }

  Future<bool> toggleGroceries(PantryItem item, bool inGroceryList) async {
    final user = auth.currentUser;

    if (user != null) {
      final newItem = item.copyWith(inGroceryList: inGroceryList);
      return await db.updateItem(newItem.name, newItem.toJson(), user);
    }
    return false;
  }

  Future<bool> changeAmount(PantryItem item, Amount amount) async {
    final user = auth.currentUser;

    if (user != null) {
      final newItem = item.copyWith(amount: amount);
      return await db.updateItem(newItem.name, newItem.toJson(), user);
    }
    return false;
  }

  Future<bool> deleteItem(PantryItem item) async {
    final user = auth.currentUser;

    if (user != null) {
      return await db.deleteItem(item.name, user);
    }
    return false;
  }

  Future<bool> addItem(PantryItem item) async {
    final user = auth.currentUser;

    if (user != null) {
      return await db.updateItem(item.name, item.toJson(), user);
    }

    return false;
  }
}
