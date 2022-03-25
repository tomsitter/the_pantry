import 'package:equatable/equatable.dart';

import '../util.dart';

class FoodCategoryException implements Exception {
  final String message;

  FoodCategoryException([this.message = "Unknown food category"]);
}

enum FoodType {
  everything,
  drinks,
  frozen,
  pantry,
  produce,
  refrigerated,
  spices,
  uncategorized,
}

extension FoodTypeX on FoodType {
  String get displayName => describeEnum(this).capitalize();
}

class FoodCategory extends Equatable {
  final FoodType category;

  static final Map<String, FoodType> categoryMap = {
    for (var foodType in FoodType.values) describeEnum(foodType): foodType
  };

  const FoodCategory(this.category);

  static const uncategorized = const FoodCategory(FoodType.uncategorized);

  static const everything = const FoodCategory(FoodType.everything);

  // Returns a lowercase String of the FoodType that can be converted back
  static String foodTypeToString(FoodType foodType) => describeEnum(foodType);

  factory FoodCategory.fromString(String category) {
    if (!categoryMap.keys.contains(category)) {
      throw FoodCategoryException("Unknown food category: $category");
    } else {
      final foodCategory = categoryMap[category]!;
      return FoodCategory(foodCategory);
    }
  }

  String get displayName => this.toString().capitalize();

  static List<FoodType> get categories => List.of(FoodType.values);
  // ..sort((a, b) =>
  //     describeEnum(a).toLowerCase().compareTo(describeEnum(b).toLowerCase()));

  @override
  String toString() => describeEnum(category);

  @override
  List<Object> get props => [category];
}
