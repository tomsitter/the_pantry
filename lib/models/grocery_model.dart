import 'dart:collection';

import 'abstract_list_model.dart';

/// [GroceryList] manages a list of [GroceryItem]s
class GroceryList extends AbstractItemList<GroceryItem> {
  GroceryList({required items}) : super(items);

  @override
  void add(String name) {
    items.add(
      GroceryItem(name: name, isSelected: false),
    );
    notifyListeners();
  }

  @override
  UnmodifiableListView<GroceryItem> sorted() {
    items.sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView(items);
  }

  void toggle(GroceryItem item) {
    item.toggleSelected();
    notifyListeners();
  }
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
