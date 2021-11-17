import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

enum Remaining { full, half, low, empty, expired }
Map<String, Remaining> remainingConverter = {
  'full': Remaining.full,
  'half': Remaining.half,
  'low': Remaining.low,
  'empty': Remaining.empty,
  'expired': Remaining.expired,
};

class UserData extends ChangeNotifier {
  GroceryList groceryList;
  PantryList pantryList;

  UserData(List<GroceryItem> items)
      : groceryList = GroceryList(items),
        pantryList = PantryList(<PantryItem>[]);

  factory UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      return UserData.fromJson(doc.data()!);
    } else {
      return UserData(<GroceryItem>[]);
    }
  }

  UserData.fromJson(Map<String, dynamic> json)
      : groceryList = GroceryList(
          json['grocery_cart']
              .entries
              .map<GroceryItem>(
                (entry) =>
                    GroceryItem(name: entry.key, isSelected: entry.value),
              )
              .toList(),
        ),
        pantryList = PantryList(json['pantry']
            .entries
            .map<PantryItem>(
              (entry) => PantryItem(
                name: entry.key,
                dateAdded: entry.value['dateAdded'].toDate(),
                remaining: remainingConverter[entry.value['remaining']] ??
                    Remaining.full,
              ),
            )
            .toList());

  Map<String, dynamic> toJson() => {
        'grocery_cart': {
          for (var item in groceryList.items) item.name: item.isSelected
        },
        'pantry': {
          for (var item in pantryList.items)
            item.name: {
              'dateAdded': item.dateAdded,
              'remaining': describeEnum(item.remaining),
            }
        }
      };

  transferItemFromGroceryToPantry(GroceryItem item) {
    groceryList.delete(item);
    pantryList.add(item.name);
  }

  transferItemFromPantryToGrocery(PantryItem item) {
    pantryList.delete(item);
    groceryList.add(item.name);
  }
}

abstract class AbstractItemList<T> {
  final List<T> _items;
  AbstractItemList(this._items);
  void add(String name);
  void delete(T item);
  void deleteAll();
  int get count;
  UnmodifiableListView<T> get items {
    return UnmodifiableListView(_items);
  }
}

/// [GroceryList] manages a list of [GroceryItem]s
class GroceryList extends AbstractItemList<GroceryItem> with ChangeNotifier {
  GroceryList(_items) : super(_items);

  @override
  void add(String name) {
    _items.add(
      GroceryItem(name: name, isSelected: false),
    );
    notifyListeners();
  }

  @override
  void delete(GroceryItem item) {
    _items.remove(item);
    notifyListeners();
  }

  @override
  void deleteAll() {
    _items.clear();
    notifyListeners();
  }

  @override
  int get count => _items.length;

  void toggle(GroceryItem item) {
    item.toggleSelected();
    notifyListeners();
  }
}

/// A [GroceryItem] has a name, and a selected state (i.e., in the grocery basket)
class GroceryItem {
  final String name;
  bool isSelected;

  GroceryItem({required this.name, this.isSelected = false});

  void toggleSelected() {
    isSelected = !isSelected;
  }
}

/// [PantryList] manages a list of [PantryItem]s
class PantryList extends AbstractItemList<PantryItem> with ChangeNotifier {
  PantryList(_items) : super(_items);

  @override
  void add(String name) {
    _items.add(
      PantryItem(name: name, dateAdded: DateTime.now()),
    );
    notifyListeners();
  }

  @override
  void delete(PantryItem item) {
    _items.remove(item);
    notifyListeners();
  }

  @override
  void deleteAll() {
    _items.clear();
    notifyListeners();
  }

  @override
  int get count => _items.length;
}

/// A [PantryItem] has a name, a date added, and a remaining amount
class PantryItem {
  final String name;
  final DateTime dateAdded;
  Remaining remaining;

  PantryItem(
      {required this.name,
      this.remaining = Remaining.full,
      required this.dateAdded});

  String daysAgo() {
    return Jiffy(dateAdded).fromNow();
  }

  void updateQuantity(Remaining newAmount) {
    remaining = newAmount;
  }
}
