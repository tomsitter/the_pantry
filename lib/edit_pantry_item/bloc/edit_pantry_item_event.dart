part of 'edit_pantry_item_bloc.dart';

abstract class EditPantryItemEvent extends Equatable {
  const EditPantryItemEvent();
}

class EditPantryItemName extends EditPantryItemEvent {
  final String name;

  const EditPantryItemName(this.name);

  @override
  List<Object?> get props => [name];
}

class EditPantryItemCategory extends EditPantryItemEvent {
  final FoodCategory category;

  const EditPantryItemCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class EditPantryItemAmount extends EditPantryItemEvent {
  final FoodAmount amount;

  const EditPantryItemAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

class EditPantryItemInGroceries extends EditPantryItemEvent {
  final bool inGroceryList;

  const EditPantryItemInGroceries(this.inGroceryList);

  @override
  List<Object?> get props => [inGroceryList];
}

class EditPantryItemSubmitted extends EditPantryItemEvent {
  const EditPantryItemSubmitted();

  @override
  List<Object?> get props => [];
}
