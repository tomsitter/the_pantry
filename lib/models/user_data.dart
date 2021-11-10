import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  List<GroceryItem> _items;

  UserData(List<GroceryItem> items) : _items = items;

  factory UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      return UserData.fromJson(doc.data()!);
    } else {
      return UserData(<GroceryItem>[]);
    }
  }

  UserData.fromJson(Map<String, dynamic> json)
      : _items = json['grocery_cart']
            .entries
            .map<GroceryItem>((entry) =>
                GroceryItem(name: entry.key, isSelected: entry.value))
            .toList();

  Map<String, dynamic> toJson() => {
        'grocery_cart': {for (var item in _items) item.name: item.isSelected}
      };

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

class GroceryItem {
  final String name;
  bool isSelected;

  GroceryItem({required this.name, this.isSelected = false});

  void toggleSelected() {
    isSelected = !isSelected;
  }
}
