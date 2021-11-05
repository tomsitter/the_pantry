import 'dart:collection';

import 'package:flutter/cupertino.dart';

class GroceryItem {
  final String name;
  bool isSelected;

  GroceryItem({required this.name, this.isSelected = false});

  void toggleSelected() {
    isSelected = !isSelected;
  }
}

class GroceryCart extends ChangeNotifier {
  final List<GroceryItem> _items;

  GroceryCart(items) : _items = items ?? [];

  UnmodifiableListView<GroceryItem> get items {
    return UnmodifiableListView(_items);
  }

  void addItem(String name, {bool isChecked = false}) {
    _items.add(
      GroceryItem(name: name, isSelected: isChecked),
    );
    notifyListeners();
  }

  void deleteItem(GroceryItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void toggleItem(GroceryItem item) {
    item.toggleSelected();
    notifyListeners();
  }

  int get count => _items.length;
}
