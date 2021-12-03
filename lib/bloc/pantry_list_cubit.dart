import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:the_pantry/data/models/pantry_model.dart';
import 'package:the_pantry/data/repository.dart';

part 'pantry_list_state.dart';

class PantryListCubit extends Cubit<PantryListState> {
  final Repository repository;

  PantryListCubit({required this.repository}) : super(PantryListInitial());

  void fetchPantryList() {
    repository.fetchPantryList().then((pantryList) {
      emit(PantryListLoaded(pantryList: pantryList));
    });
  }

  void toggleChecked(PantryItem item, {bool? status}) {
    repository.toggleChecked(item, status ?? !item.isChecked).then((success) {
      if (success) {
        item.isChecked = !item.isChecked;
        updatePantryList();
      }
    });
  }

  void toggleGroceries(PantryItem item, {bool? status}) {
    repository
        .toggleGroceries(item, status ?? !item.inGroceryList)
        .then((success) {
      if (success) {
        item.inGroceryList = !item.inGroceryList;
        updatePantryList();
      }
    });
  }

  void updatePantryList() {
    final currentState = state;
    if (currentState is PantryListLoaded) {
      emit(PantryListLoaded(pantryList: currentState.pantryList));
    }
  }

  void deleteItem(PantryItem item) {
    final currentState = state;
    repository.deleteItem(item).then((success) {
      if (success) {
        if (currentState is PantryListLoaded) {
          final newList = currentState.pantryList;
          newList.delete(item);
          emit(PantryListLoaded(pantryList: newList));
        }
        //currentState.pantryList.
      }
    });
  }

  void addItem(PantryItem newItem) {
    final currentState = state;
    if (currentState is PantryListLoaded) {
      final pantryList = currentState.pantryList;
      pantryList.add(newItem);
      emit(PantryListLoaded(pantryList: pantryList));
    }
  }
}
