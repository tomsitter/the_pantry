import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:jiffy/jiffy.dart';

import 'abstract_list_model.dart';

/// Amount of remaining product, or expired
enum Amount { full, half, low, empty, expired }

/// Helper to convert between String <-> eNum for Firebase
Map<String, Amount> amountConverter = {
  'full': Amount.full,
  'half': Amount.half,
  'low': Amount.low,
  'empty': Amount.empty,
  'expired': Amount.expired,
};

/// [PantryList] manages a list of [PantryItem]s and is a [ChangeNotifier]
///
/// You can add to, delete from, and clear the list of items. You can also get
/// a count of items. You can also update the amount of item remaining
class PantryList extends AbstractItemList<PantryItem> {
  PantryList({required items}) : super(items);

  @override
  void add(String name) {
    items.add(
      PantryItem(name: name, dateAdded: DateTime.now()),
    );
    notifyListeners();
  }

  void updateItemAmount(PantryItem item, String newAmount) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      if (amountConverter.containsKey(newAmount)) {
        Amount amount = amountConverter[newAmount]!;
        items[itemIndex].updateQuantity(amount);
        notifyListeners();
      } else {
        print('The amount $newAmount is not a known amount');
      }
    } else {
      print('Item ${item.name} not found!');
    }
  }

  @override
  UnmodifiableListView<PantryItem> sorted() {
    items.sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView(items);
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
