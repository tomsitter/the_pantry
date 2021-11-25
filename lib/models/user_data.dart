import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'abstract_list_model.dart';
import 'pantry_model.dart';
import 'grocery_model.dart';

class UserData extends ChangeNotifier {
  GroceryList groceryList;
  PantryList pantryList;

  UserData(List<GroceryItem> items)
      : groceryList = GroceryList(items: items),
        pantryList = PantryList(items: <PantryItem>[]);

  factory UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      return UserData.fromJson(doc.data()!);
    } else {
      return UserData(<GroceryItem>[]);
    }
  }

  UserData.fromJson(Map<String, dynamic> json)
      : groceryList = GroceryList(
          items: json['grocery_cart']
              .entries
              .map<GroceryItem>(
                (entry) => GroceryItem(
                  name: entry.key,
                  isSelected: entry.value['isSelected'] ?? false,
                  foodType: foodTypeMap[entry.value['foodType']] ??
                      FoodType.uncategorized,
                ),
              )
              .toList(),
        ),
        pantryList = PantryList(
            items: json['pantry']
                .entries
                .map<PantryItem>(
                  (entry) => PantryItem(
                    name: entry.key,
                    dateAdded: entry.value['dateAdded'].toDate(),
                    foodType: foodTypeMap[entry.value['foodType']] ??
                        FoodType.uncategorized,
                    amount: amountMap[entry.value['amount']] ?? Amount.full,
                  ),
                )
                .toList());

  Map<String, dynamic> toJson() => {
        'grocery_cart': {
          for (var item in groceryList.items)
            item.name: {
              'isSelected': item.isSelected,
              'foodType': describeEnum(item.foodType),
            }
        },
        'pantry': {
          for (var item in pantryList.items)
            item.name: {
              'dateAdded': item.dateAdded,
              'amount': describeEnum(item.amount),
              'foodType': describeEnum(item.foodType),
            }
        }
      };

  transferFromGroceryToPantry(GroceryItem item) {
    groceryList.delete(item);
    pantryList.add(PantryItem(name: item.name, foodType: item.foodType));
  }

  transferFromPantryToGrocery(PantryItem item) {
    pantryList.delete(item);
    groceryList.add(GroceryItem(name: item.name, foodType: item.foodType));
  }
}
