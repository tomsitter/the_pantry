import 'package:pantry_repository/pantry_repository.dart';

enum PantryViewFilter {
  all,
  uncheckedOnly,
  checkedOnly,
  groceriesOnly,
  pantryOnly
}

extension PantryViewFilterX on PantryViewFilter {
  bool apply(PantryItem item) {
    switch (this) {
      case PantryViewFilter.all:
        return true;
      case PantryViewFilter.checkedOnly:
        return item.isChecked;
      case PantryViewFilter.uncheckedOnly:
        return !item.isChecked;
      case PantryViewFilter.groceriesOnly:
        return item.inGroceryList;
      case PantryViewFilter.pantryOnly:
        return !item.inGroceryList;
    }
  }

  Iterable<PantryItem> applyAll(Iterable<PantryItem> items) {
    return items.where(apply);
  }
}
