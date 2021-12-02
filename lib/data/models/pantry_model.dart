import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';

/// Amount of remaining product, or expired
enum Amount { full, half, low, empty, expired }

/// Helper to convert between String <-> eNum for Firebase
Map<String, Amount> amountMap = {
  for (var amount in Amount.values) describeEnum(amount): amount
};

enum FoodType {
  fresh,
  frozen,
  nonperishable,
  pantry,
  produce,
  refrigerated,
  spices,
  uncategorized,
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension FoodTypeExtension on FoodType {
  String get displayName => describeEnum(this).capitalize();
}

Map<String, FoodType> foodTypeMap = {
  for (var category in FoodType.values) describeEnum(category): category
};

/// Get unique values of a property on an iterable of objects
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
class PantryList extends ChangeNotifier {
  List<PantryItem> items = <PantryItem>[];

  PantryList({required this.items});

  factory PantryList.fromJson(Map<String, dynamic> json) {
    return PantryList(
        items: json['pantry']
            .entries
            .map<PantryItem>((item) => PantryItem.fromJson(item))
            .toList());
  }

  factory PantryList.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      return PantryList.fromJson(doc.data()!);
    } else {
      return PantryList(items: <PantryItem>[]);
    }
  }

  Map<String, dynamic> toJson() => {
        'pantry': {
          for (var item in items)
            item.name: {
              'isChecked': item.isChecked,
              'inGroceryList': item.inGroceryList,
              'dateAdded': item.dateAdded,
              'foodType': describeEnum(item.foodType),
              'amount': describeEnum(item.amount),
            }
        }
      };

  void add(PantryItem item) {
    items.add(item);
    notifyListeners();
  }

  void delete(PantryItem item) {
    items.remove(item);
    notifyListeners();
  }

  /// Delete all items
  void clear() {
    items.clear();
    notifyListeners();
  }

  int get count => items.length;

  int get countGroceries =>
      items.where((item) => item.inGroceryList == true).length;

  List<PantryItem> get groceries =>
      items.where((item) => item.inGroceryList == true).toList();

  List<PantryItem> get pantry =>
      items.where((item) => item.inGroceryList == false).toList();

  /// Toogle an items isChecked property
  void toggle(PantryItem item) {
    item.isChecked = !item.isChecked;
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
    if (itemIndex >= 0 && amountMap.containsKey(newAmount)) {
      Amount amount = amountMap[newAmount]!;
      items[itemIndex].amount = amount;
      notifyListeners();
    }
  }

  void addToGroceries(PantryItem item) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      items[itemIndex].inGroceryList = true;
    }
    notifyListeners();
  }

  void removeFromGroceries(PantryItem item) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      items[itemIndex].inGroceryList = false;
      items[itemIndex].amount = Amount.full;
      items[itemIndex].isChecked = false;
      items[itemIndex].dateAdded = DateTime.now();
    }
    notifyListeners();
  }

  UnmodifiableListView<PantryItem> sorted() {
    items.sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView(items);
  }
}

/// A [PantryItem] has a name, a date added, and an amount
///
/// PantryItems can return how long ago they were added to the pantry list
/// and can have the amount of product changed
class PantryItem {
  /// The name of the item.
  final String name;

  /// The category of food type of the item.
  FoodType foodType;

  /// Date this item was added to the pantry, resets when taken off grocery list
  late DateTime dateAdded;

  /// Amount of food remaining
  Amount amount = Amount.full;

  /// Whether this item has been added to the grocery list
  bool inGroceryList = false;

  /// Used when item is in a grocery list
  bool isChecked;

  PantryItem({
    required this.name,
    this.isChecked = false,
    this.inGroceryList = false,
    this.amount = Amount.full,
    this.foodType = FoodType.uncategorized,
    dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory PantryItem.fromJson(dynamic json) {
    return PantryItem(
      name: json.key,
      isChecked: json.value['isChecked'] ?? false,
      inGroceryList: json.value['inGroceryList'] ?? false,
      dateAdded: json.value['dateAdded'] != null
          ? json.value['dateAdded'].toDate()
          : DateTime.now(),
      foodType: foodTypeMap[json.value['foodType']] ?? FoodType.uncategorized,
      amount: amountMap[json.value['amount']] ?? Amount.full,
    );
  }

  Map<String, dynamic> toJson() => {
        name: {
          'isChecked': isChecked,
          'inGroceryList': inGroceryList,
          'dateAdded': dateAdded,
          'foodType': describeEnum(foodType),
          'amount': describeEnum(amount),
        }
      };

  PantryItem copyWith({
    String? name,
    bool? isChecked,
    bool? inGroceryList,
    Amount? amount,
    FoodType? foodType,
  }) {
    return PantryItem(
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      inGroceryList: inGroceryList ?? this.inGroceryList,
      amount: amount ?? this.amount,
      foodType: foodType ?? this.foodType,
    );
  }

  String daysAgo() {
    return Jiffy(dateAdded).fromNow();
  }
}
