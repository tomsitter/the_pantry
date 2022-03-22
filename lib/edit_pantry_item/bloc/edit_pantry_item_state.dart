part of 'edit_pantry_item_bloc.dart';

enum EditPantryItemStatus { initial, loading, success, failure }

extension EditPantryItemStatusX on EditPantryItemStatus {
  bool get isLoadingOrSuccess => [
        EditPantryItemStatus.loading,
        EditPantryItemStatus.success,
      ].contains(this);
}

class EditPantryItemState extends Equatable {
  final EditPantryItemStatus status;
  final PantryItem? initialItem;
  final String name;
  final FoodCategory category;
  final FoodAmount amount;
  final bool? inGroceryList;

  bool get isNewItem => initialItem == null;

  const EditPantryItemState({
    this.status = EditPantryItemStatus.initial,
    this.initialItem,
    this.name = '',
    this.category = FoodCategory.uncategorized,
    this.amount = FoodAmount.full,
    this.inGroceryList,
  });

  EditPantryItemState copyWith({
    EditPantryItemStatus? status,
    PantryItem? initialItem,
    String? name,
    FoodCategory? category,
    FoodAmount? amount,
    bool? inGroceryList,
  }) {
    return EditPantryItemState(
      status: status ?? this.status,
      initialItem: initialItem ?? this.initialItem,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      inGroceryList: inGroceryList ?? this.inGroceryList,
    );
  }

  @override
  List<Object?> get props =>
      [status, initialItem, name, category, amount, inGroceryList];
}
