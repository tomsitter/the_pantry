import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

enum Amount { full, half, low, empty, expired }
enum Category { produce, refrigerated, frozen, nonperishable, uncategorized }
Map<String, Amount> amountConverter = {
  'full': Amount.full,
  'half': Amount.half,
  'low': Amount.low,
  'empty': Amount.empty,
  'expired': Amount.expired,
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
                amount: amountConverter[entry.value['amount']] ?? Amount.full,
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
              'amount': describeEnum(item.amount),
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

abstract class AbstractItemList<AbstractItem> {
  final List<AbstractItem> _items;
  AbstractItemList(this._items);
  void add(String name);
  void delete(AbstractItem item);
  void clear();
  int get count;

  UnmodifiableListView<AbstractItem> get items {
    return UnmodifiableListView(
        _items); // .sort((a, b) => a.name.compareTo(b.name);
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
  void clear() {
    _items.clear();
    notifyListeners();
  }

  @override
  int get count => _items.length;

  void toggle(GroceryItem item) {
    item.toggleSelected();
    notifyListeners();
  }

  @override
  UnmodifiableListView<GroceryItem> get items {
    _items.sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView(_items);
  }
}

/// [PantryList] manages a list of [PantryItem]s and is a [ChangeNotifier]
///
/// You can add to, delete from, and clear the list of items. You can also get
/// a count of items. You can also update the amount of item remaining
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
  void clear() {
    _items.clear();
    notifyListeners();
  }

  @override
  int get count => _items.length;

  void updateItemAmount(PantryItem item, String newAmount) {
    var itemIndex = _items.indexOf(item);
    if (itemIndex >= 0) {
      if (amountConverter.containsKey(newAmount)) {
        Amount amount = amountConverter[newAmount]!;
        _items[itemIndex].updateQuantity(amount);
        notifyListeners();
      } else {
        print('The amount $newAmount is not a known amount');
      }
    } else {
      print('Item ${item.name} not found!');
    }
  }

  @override
  UnmodifiableListView<PantryItem> get items {
    _items.sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView(_items);
  }
}

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

  void updateCategory(Category newCategory) {
    category = newCategory;
  }

  AbstractItem({required this.name, this.category = Category.uncategorized});
}

/// A [GroceryItem] has a name, a category, and a selected state (i.e., in the grocery basket)
///
/// A grocery item can toggle whether it is selected or not, and inherits a
/// category that can be updated
class GroceryItem extends AbstractItem {
  /// The state of whether the item should show as checked or not
  bool isSelected;

  GroceryItem({name, this.isSelected = false}) : super(name: name);

  void toggleSelected() {
    isSelected = !isSelected;
  }
}

/// A [PantryItem] has a name, a date added, and an amount
///
/// PantryItems can return how long ago they were added to the pantry list
/// and can have the amount of product changed
class PantryItem extends AbstractItem {
  final DateTime dateAdded;
  Amount amount;

  PantryItem({name, this.amount = Amount.full, required this.dateAdded})
      : super(name: name);

  String daysAgo() {
    return Jiffy(dateAdded).fromNow();
  }

  void updateQuantity(Amount newAmount) {
    amount = newAmount;
  }
}
