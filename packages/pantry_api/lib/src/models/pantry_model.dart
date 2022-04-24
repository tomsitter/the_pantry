import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pantry_api/pantry_api.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

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

/// Returns a list of unique [FoodCategory]s for all [items]
List<FoodCategory> uniqueFoodTypes(List<PantryItem> items) {
  return items
      .distinctBy((x) => x.category)
      .map((item) => item.category)
      .toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));
}

/// Returns all [items] of a specific [FoodCategory]
List<PantryItem> ofFoodType(FoodCategory category, List<PantryItem> items) {
  return items.where((item) => item.category == category).toList();
}

/// A [PantryItem] has a name, a date added, and an amount remaining
/// [PantryItem]s can be in the grocery list, and can be checked or not
///
/// Use the [daysAgo] method for a human-readable string for how long ago
/// the item was added to the pantry list
class PantryItem extends Equatable implements Comparable<PantryItem> {
  final String id;

  /// The name of the item.
  final String name;

  /// The category of food type of the item.
  final FoodCategory category;

  /// Date this item was added to the pantry, resets when taken off grocery list
  late final DateTime dateAdded;

  /// Amount of food remaining
  final FoodAmount amount;

  /// Whether this item has been added to the grocery list
  final bool inGroceryList;

  /// Used when item is in a grocery list
  final bool isChecked;

  PantryItem({
    id,
    required this.name,
    this.isChecked = false,
    this.inGroceryList = false,
    this.amount = FoodAmount.full,
    this.category = FoodCategory.uncategorized,
    dateAdded,
  })  : dateAdded = dateAdded ?? DateTime.now(),
        id = id ?? uuid.v1();

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      isChecked: json['isChecked'] ?? false,
      inGroceryList: json['inGroceryList'] ?? false,
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : DateTime.now(),
      category: FoodCategory.fromString(json['category']),
      amount: json['amount'] != null
          ? FoodAmount.fromString(json['amount'])
          : FoodAmount.full,
    );
  }

  factory PantryItem.fromFirestore(MapEntry<String, dynamic> json) {
    return PantryItem(
      id: json.key,
      name: json.value['name'],
      isChecked: json.value['isChecked'] ?? false,
      inGroceryList: json.value['inGroceryList'] ?? false,
      dateAdded: json.value['dateAdded'] != null
          ? json.value['dateAdded'].toDate()
          : DateTime.now(),
      category: FoodCategory.fromString(json.value['category']),
      amount: json.value['amount'] != null
          ? FoodAmount.fromString(json.value['amount'])
          : FoodAmount.full,
    );
  }

  Map<String, dynamic> toJson() => {
        id: {
          'name': name,
          'isChecked': isChecked,
          'inGroceryList': inGroceryList,
          'dateAdded': dateAdded,
          'category': category.toString(),
          'amount': amount.toString(),
        }
      };

  PantryItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
    bool? inGroceryList,
    FoodAmount? amount,
    FoodCategory? category,
    DateTime? dateAdded,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      inGroceryList: inGroceryList ?? this.inGroceryList,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  String daysAgo() {
    return Jiffy(dateAdded).fromNow();
  }

  @override
  List<Object?> get props =>
      [id, name, isChecked, inGroceryList, amount, category, dateAdded];

  /// Pantry Items are sorted by category then by name
  @override
  int compareTo(PantryItem other) {
    int comparison = category.compareTo(other.category);
    // If both food items are in the same category, then sort by name
    return comparison == 0 ? name.compareTo(other.name) : comparison;
  }
}
