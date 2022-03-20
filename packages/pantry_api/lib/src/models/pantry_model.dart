import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';

/// Helper function to convert enum value to String representation
/// https://api.flutter.dev/flutter/foundation/describeEnum.html
String _describeEnum(Object enumEntry) {
  if (enumEntry is Enum) return enumEntry.name;
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(
    indexOfDot != -1 && indexOfDot < description.length - 1,
    'The provided object "$enumEntry" is not an enum.',
  );
  return description.substring(indexOfDot + 1);
}

/// Amount of remaining product, or expired
enum Amount { full, half, low, empty, expired }

/// Helper to convert between String <-> eNum for Firebase
Map<String, Amount> amountMap = {
  for (var amount in Amount.values) _describeEnum(amount): amount
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
  String get displayName => _describeEnum(this).capitalize();
}

Map<String, FoodType> foodTypeMap = {
  for (var category in FoodType.values) _describeEnum(category): category
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
class PantryList {
  List<PantryItem> items = <PantryItem>[];

  PantryList({required this.items});

  factory PantryList.fromJson(Map<String, dynamic> json) {
    return PantryList(
        items: json['pantry']
            .entries
            .map<PantryItem>((item) => PantryItem.fromJson(item))
            .toList());
  }

  // factory PantryList.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  //   if (doc.data() != null) {
  //     return PantryList.fromJson(doc.data()!);
  //   } else {
  //     return PantryList(items: <PantryItem>[]);
  //   }
  // }

  Map<String, dynamic> toJson() => {
        'pantry': {
          for (var item in items)
            item.name: {
              'isChecked': item.isChecked,
              'inGroceryList': item.inGroceryList,
              'dateAdded': item.dateAdded,
              'foodType': _describeEnum(item.foodType),
              'amount': _describeEnum(item.amount),
            }
        }
      };

  bool hasItem(String itemName) {
    return items.where((item) => item.name == itemName).isNotEmpty;
  }

  void add(PantryItem item) {
    items.add(item);
  }

  void delete(PantryItem item) {
    items.remove(item);
  }

  /// Delete all items
  void clear() {
    items.clear();
  }

  int get count => items.length;

  int get countGroceries =>
      items.where((item) => item.inGroceryList == true).length;

  List<PantryItem> get groceries =>
      items.where((item) => item.inGroceryList == true).toList();

  List<PantryItem> get pantry =>
      items.where((item) => item.inGroceryList == false).toList();

  /// Toggle an item's isChecked property
  void toggle(PantryItem item) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      items[itemIndex] = item.copyWith(
        isChecked: !item.isChecked,
      );
    }
  }

  /// Return an alphabetically sorted list of unique food types for the
  /// items in the users pantry
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
      items[itemIndex] = item.copyWith(amount: amountMap[newAmount]!);
    }
  }

  void addToGroceries(PantryItem item) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      items[itemIndex] = item.copyWith(
        inGroceryList: true,
        dateAdded: DateTime.now(),
      );
    }
  }

  void removeFromGroceries(PantryItem item) {
    var itemIndex = items.indexOf(item);
    if (itemIndex >= 0) {
      items[itemIndex] = item.copyWith(
        inGroceryList: false,
        amount: Amount.full,
        isChecked: false,
        dateAdded: DateTime.now(),
      );
    }
  }

  UnmodifiableListView<PantryItem> sorted() {
    items.sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView(items);
  }
}

/// A [PantryItem] has a name, a date added, and an amount remaining
/// [PantryItem]s can be in the grocery list, and can be checked or not
///
/// Use the [daysAgo] method for a human-readable string for how long ago
/// the item was added to the pantry list
class PantryItem extends Equatable {
  /// The name of the item.
  final String name;

  /// The category of food type of the item.
  final FoodType foodType;

  /// Date this item was added to the pantry, resets when taken off grocery list
  late final DateTime dateAdded;

  /// Amount of food remaining
  final Amount amount;

  /// Whether this item has been added to the grocery list
  final bool inGroceryList;

  /// Used when item is in a grocery list
  final bool isChecked;

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
          'foodType': _describeEnum(foodType),
          'amount': _describeEnum(amount),
        }
      };

  PantryItem copyWith({
    String? name,
    bool? isChecked,
    bool? inGroceryList,
    Amount? amount,
    FoodType? foodType,
    DateTime? dateAdded,
  }) {
    return PantryItem(
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      inGroceryList: inGroceryList ?? this.inGroceryList,
      amount: amount ?? this.amount,
      foodType: foodType ?? this.foodType,
      dateAdded: () => dateAdded ?? this.dateAdded,
    );
  }

  String daysAgo() {
    return Jiffy(dateAdded).fromNow();
  }

  @override
  List<Object?> get props => [name, isChecked, inGroceryList, amount, foodType];
}
