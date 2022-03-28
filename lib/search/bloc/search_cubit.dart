import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:the_pantry/search/search.dart';
import 'package:pantry_repository/pantry_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final PantryRepository _pantryRepository;
  late StreamSubscription _pantryStreamSubscription;

  SearchCubit(
      {required PantryRepository pantryRepository,
      required FoodRepository foodRepository})
      : _pantryRepository = pantryRepository,
        super(SearchState(
          items: foodRepository.foodItems,
        )) {
    monitorUserPantryItems();
  }

  void monitorUserPantryItems() {
    _pantryStreamSubscription =
        _pantryRepository.getPantryItems().listen((items) {
      state.copyWith(userItems: items);
    });
  }

  void changeTarget(SearchTarget target) {
    emit(state.copyWith(target: target));
  }

  void changeSearchText(String searchText) {
    emit(state.copyWith(searchText: searchText));
  }

  @override
  Future<void> close() {
    _pantryStreamSubscription.cancel();
    return super.close();
  }
}
