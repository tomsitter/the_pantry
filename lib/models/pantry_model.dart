import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';

import 'abstract_list_model.dart';

/// Amount of remaining product, or expired
enum Amount { full, half, low, empty, expired }

/// Helper to convert between String <-> eNum for Firebase
Map<String, Amount> amountMap = {
  for (var amount in Amount.values) describeEnum(amount): amount
};

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];
    forEach((element) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    });

    return result;
  }
}

/// [PantryList] manages a list of [PantryItem]s and is a [ChangeNotifier]
///
/// You can add to, delete from, and clear the list of items. You can also get
/// a count of items. You can also update the amount of item remaining
class PantryList extends AbstractItemList<PantryItem> {
  PantryList({required items}) : super(items);

  @override
  void add(PantryItem item) {
    items.add(item);
    notifyListeners();
  }

  List<FoodType> uniqueFoodTypes() {
    return items
        .distinctBy((x) => x.foodType)
        .map((item) => item.foodType)
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  List<PantryItem> ofFoodType(FoodType foodType) {
    return items.where((item) => item.foodType == foodType).toList();
  }

  void updateItemAmount(PantryItem item, String newAmount) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      if (amountMap.containsKey(newAmount)) {
        Amount amount = amountMap[newAmount]!;
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

  PantryItem(
      {name,
      this.amount = Amount.full,
      FoodType foodType = FoodType.uncategorized,
      DateTime? dateAdded})
      : dateAdded = dateAdded ?? DateTime.now(),
        super(name: name, foodType: foodType);

  String daysAgo() {
    return Jiffy(dateAdded).fromNow();
  }

  void updateQuantity(Amount newAmount) {
    amount = newAmount;
  }
}
