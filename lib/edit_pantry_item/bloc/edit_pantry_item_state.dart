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
  final FormzStatus formStatus;
  final bool isGroceryScreen;
  final PantryItem? initialItem;
  final ItemName name;
  final FoodCategory category;
  final FoodAmount amount;
  final bool? inGroceryList;

  bool get isNewItem => initialItem == null;
  bool get isFormValid => formStatus.isValidated;

  const EditPantryItemState({
    this.status = EditPantryItemStatus.initial,
    this.formStatus = FormzStatus.pure,
    required this.isGroceryScreen,
    this.initialItem,
    this.name = const ItemName.pure(),
    this.category = FoodCategory.uncategorized,
    this.amount = FoodAmount.full,
    this.inGroceryList,
  });

  EditPantryItemState copyWith({
    EditPantryItemStatus? status,
    FormzStatus? formStatus,
    bool? isGroceryScreen,
    PantryItem? initialItem,
    ItemName? name,
    FoodCategory? category,
    FoodAmount? amount,
    bool? inGroceryList,
  }) {
    return EditPantryItemState(
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      isGroceryScreen: isGroceryScreen ?? this.isGroceryScreen,
      initialItem: initialItem ?? this.initialItem,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      inGroceryList: inGroceryList ?? this.inGroceryList,
    );
  }

  @override
  List<Object?> get props => [
        status,
        formStatus,
        isGroceryScreen,
        name,
        category,
        amount,
        inGroceryList
      ];
}
