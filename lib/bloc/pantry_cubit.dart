import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_pantry/data/models/pantry_model.dart';
import 'package:the_pantry/data/repositories/firestore_repository.dart';

part 'pantry_state.dart';

class PantryCubit extends Cubit<PantryState> {
  final Repository repository;

  PantryCubit({required this.repository}) : super(PantryState.initial());

  void addItem(String itemName, bool inGroceryList) {
    if (itemName.isEmpty) {
      emit(state.copyWith(
          status: PantryStatus.error,
          error: "New item must have a unique name"));
      return;
    }

    if (state.pantryList.hasItem(itemName)) {
      emit(state.copyWith(
          status: PantryStatus.error, error: "Item is already in your pantry"));
      return;
    }

    PantryItem newItem =
        PantryItem(name: itemName, inGroceryList: inGroceryList);

    emit(state.copyWith(status: PantryStatus.updating));

    repository.addItem(newItem).then((success) {
      if (success) {
        emit(state.copyWith(status: PantryStatus.loaded));
        state.pantryList.add(newItem);
      } else {
        emit(state.copyWith(
            status: PantryStatus.error, error: "Failed to add new item"));
      }
    });
  }

  void fetchPantryList() async {
    emit(state.copyWith(
      status: PantryStatus.loading,
    ));
    await repository.fetchPantryList().then((pantryList) {
      print("Emitting loaded pantry");
      emit(state.copyWith(status: PantryStatus.loaded, pantryList: pantryList));
    });
  }

  void toggleChecked(PantryItem item, {bool? status}) {
    emit(state.copyWith(status: PantryStatus.updating));

    repository.toggleChecked(item, status ?? !item.isChecked).then((success) {
      if (success) {
        item.isChecked = !item.isChecked;
        emit(state.copyWith(
          status: PantryStatus.loaded,
        ));
      } else {
        emit(state.copyWith(
            status: PantryStatus.error, error: "Could not toggle item"));
      }
    });
  }

  void toggleGroceries(PantryItem item, {bool? status}) {
    emit(state.copyWith(status: PantryStatus.updating));

    repository
        .toggleGroceries(item, status ?? !item.inGroceryList)
        .then((success) {
      if (success) {
        item.inGroceryList = !item.inGroceryList;
        emit(state.copyWith(
          status: PantryStatus.loaded,
        ));
      } else {
        emit(state.copyWith(
            status: PantryStatus.error, error: "Could not toggle item"));
      }
    });
  }

  void changeAmount(PantryItem item, String amount) {
    emit(state.copyWith(status: PantryStatus.updating));

    if (amountMap.containsKey(amount)) {
      Amount newAmount = amountMap[amount]!;
      repository.changeAmount(item, newAmount).then((success) {
        if (success) {
          item.amount = newAmount;
          emit(state.copyWith(
            status: PantryStatus.loaded,
          ));
        } else {
          emit(state.copyWith(
              status: PantryStatus.error, error: "Could not change amount"));
        }
      });
    }
  }

  void deleteItem(PantryItem item) {
    emit(state.copyWith(status: PantryStatus.updating));

    repository.deleteItem(item).then((success) {
      if (success) {
        state.pantryList.delete(item);
        emit(state.copyWith(status: PantryStatus.loaded));
      } else {
        emit(state.copyWith(
            status: PantryStatus.error, error: "Could not delete item"));
      }
    });
  }
}
