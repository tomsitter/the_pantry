part of 'pantry_list_cubit.dart';

@immutable
abstract class PantryListState {}

class PantryListInitial extends PantryListState {}

class PantryListLoaded extends PantryListState {
  final PantryList pantryList;

  PantryListLoaded({required this.pantryList});
}
