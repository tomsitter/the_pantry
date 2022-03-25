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
  final FormzStatus _formStatus;
  final bool isGroceryScreen;
  final PantryItem? initialItem;
  final ItemName name;
  final FoodCategory category;
  final FoodAmount amount;
  final bool? inGroceryList;

  bool get isNewItem => initialItem == null;
  bool get isFormValid => _formStatus.isValidated;
  bool get canSubmit => isFormValid && !status.isLoadingOrSuccess;

  EditPantryItemState({
    this.status = EditPantryItemStatus.initial,
    formStatus,
    required this.isGroceryScreen,
    this.initialItem,
    this.name = const ItemName.pure(),
    this.category = FoodCategory.uncategorized,
    this.amount = FoodAmount.full,
    this.inGroceryList,
  }) : _formStatus = formStatus ?? Formz.validate([name]);

  EditPantryItemState copyWith({
    EditPantryItemStatus? status,
    List<PantryItem>? searchMatches,
    bool? isGroceryScreen,
    PantryItem? initialItem,
    ItemName? name,
    FoodCategory? category,
    FoodAmount? amount,
    bool? inGroceryList,
  }) {
    return EditPantryItemState(
      status: status ?? this.status,
      formStatus: Formz.validate([name ?? this.name]),
      isGroceryScreen: isGroceryScreen ?? this.isGroceryScreen,
      initialItem: initialItem ?? this.initialItem,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      inGroceryList: inGroceryList ?? this.inGroceryList,
    );
  }

  @override
  List<Object?> get props =>
      [status, isGroceryScreen, name, category, amount, inGroceryList];
}
