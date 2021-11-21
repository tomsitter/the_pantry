import 'dart:collection';

import 'package:flutter/cupertino.dart';

enum Category { produce, refrigerated, frozen, nonperishable, uncategorized }

/// Abstract class for [GroceryItem]s and [PantryItem]s so some widgets can
/// accept either type.
///
/// Abstract items have a name and a category. The name cannot be changed but
/// the category can.
class AbstractItem {
  /// The name of the item.
  final String name;

  /// The category of food type of the item.
  Category category;

  AbstractItem({required this.name, this.category = Category.uncategorized});

  void setCategory(Category newCategory) {
    category = newCategory;
  }
}

/// Abstract class for [GroceryList] and [PantryList] so some widgets
/// can accept either type.
///
/// Abstract lists contain a list of of concrete items that cna be add, deleted,
/// cleared, counted and view.
abstract class AbstractItemList<AbstractItem> extends ChangeNotifier {
  final List<AbstractItem> items;

  AbstractItemList(this.items);

  void add(String name);

  void delete(AbstractItem item) {
    items.remove(item);
    notifyListeners();
  }

  /// Delete all items
  void clear() {
    items.clear();
    notifyListeners();
  }

  /// Returns a sorted unmodifiable list of items, sorts by name
  UnmodifiableListView<AbstractItem> sorted();

  int get count => items.length;
}
