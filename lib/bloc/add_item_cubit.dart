import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:the_pantry/bloc/pantry_list_cubit.dart';
import 'package:the_pantry/data/models/pantry_model.dart';
import 'package:the_pantry/data/repository.dart';

part 'add_item_state.dart';

class AddItemCubit extends Cubit<AddItemState> {
  final Repository repository;
  final PantryListCubit pantryListCubit;

  AddItemCubit({required this.repository, required this.pantryListCubit})
      : super(AddItemInitial());

  void addItem(String itemName, bool inGroceryList) {
    if (itemName.isEmpty) {
      emit(AddItemError(error: "New item must have a unique name"));
      return;
    }

    emit(AddItemInProgress());
    PantryItem newItem =
        PantryItem(name: itemName, inGroceryList: inGroceryList);
    repository.addItem(newItem).then((success) {
      if (success) {
        pantryListCubit.addItem(newItem);
        emit(AddItemComplete());
      } else {
        emit(AddItemError(error: "Failed to add new item"));
      }
    });
  }
}
