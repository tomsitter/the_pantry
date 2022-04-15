import 'package:pantry_repository/pantry_repository.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class FoodRepository {
  late final List<PantryItem> foodItems;

  FoodRepository({required this.foodItems});

  factory FoodRepository.fromJson(data) {
    return FoodRepository(
        foodItems:
            data.map<PantryItem>((item) => PantryItem.fromJson(item)).toList());
  }

  List<PantryItem>? findItemByName(String name) {
    return foodItems.where((item) => item.name.contains(name)).toList();
  }

  List<PantryItem>? findItemByNameAndCategory(String name, String category) {
    final foodCategory = FoodCategory.fromString(category);
    return foodItems
        .where(
            (item) => item.name.contains(name) && item.category == foodCategory)
        .toList();
  }

// void loadFoodItems() async {
//   final data = await rootBundle.loadString('assets/data/foods.json');
//   final List<Map<String, String>> parsedData = json.decode(data);
//
// }
}
