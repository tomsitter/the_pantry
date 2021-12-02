part of 'add_item_cubit.dart';

@immutable
abstract class AddItemState {}

class AddItemInitial extends AddItemState {}

class AddItemError extends AddItemState {
  final String error;

  AddItemError({required this.error});
}

class AddingItem extends AddItemState {}

class ItemAdded extends AddItemState {}
