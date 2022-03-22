import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_repository/pantry_repository.dart';

part 'edit_pantry_item_event.dart';
part 'edit_pantry_item_state.dart';

class EditPantryItemBloc
    extends Bloc<EditPantryItemEvent, EditPantryItemState> {
  final PantryRepository _pantryRepository;
  final AuthenticationRepository _authRepository;

  EditPantryItemBloc(
      {required PantryRepository pantryRepository,
      required AuthenticationRepository authRepository,
      required PantryItem? initialItem})
      : _pantryRepository = pantryRepository,
        _authRepository = authRepository,
        super(EditPantryItemState(
          initialItem: initialItem,
          name: initialItem?.name ?? '',
          category: initialItem?.category ?? FoodCategory.uncategorized,
          inGroceryList: initialItem?.inGroceryList ?? true,
        )) {
    on<EditPantryItemName>(_onNameChanged);
    on<EditPantryItemCategory>(_onCategoryChanged);
    on<EditPantryItemAmount>(_onAmountChanged);
    on<EditPantryItemSubmitted>(_onSubmitted);
    on<EditPantryItemInGroceries>(_onInGroceriesChanged);
  }

  void _onNameChanged(
    EditPantryItemName event,
    Emitter<EditPantryItemState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onCategoryChanged(
    EditPantryItemCategory event,
    Emitter<EditPantryItemState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  void _onAmountChanged(
    EditPantryItemAmount event,
    Emitter<EditPantryItemState> emit,
  ) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onInGroceriesChanged(
    EditPantryItemInGroceries event,
    Emitter<EditPantryItemState> emit,
  ) {
    emit(state.copyWith(inGroceryList: event.inGroceryList));
  }

  /// Uploads a new item if no initialItem, otherwise updates an existing
  /// item with the same id.
  void _onSubmitted(
    EditPantryItemSubmitted event,
    Emitter<EditPantryItemState> emit,
  ) async {
    emit(state.copyWith(status: EditPantryItemStatus.loading));
    final item = (state.initialItem ?? PantryItem(name: '')).copyWith(
      name: state.name,
      category: state.category,
      amount: state.amount,
      inGroceryList: state.inGroceryList,
    );

    try {
      await _pantryRepository.savePantryItem(
          _authRepository.currentUser.id, item);
      emit(state.copyWith(status: EditPantryItemStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditPantryItemStatus.failure));
    }
  }
}
