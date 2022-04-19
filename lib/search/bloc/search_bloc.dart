import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/search/search.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
      {required FoodRepository foodRepository, List<PantryItem>? userItems})
      : super(SearchState(
            items: foodRepository.foodItems, userItems: userItems ?? [])) {
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchTextChanged>(_onSearchTextChanged);
  }

  Future<void> _onFilterChanged(
      SearchFilterChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onSearchTextChanged(
      SearchTextChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(filter: SearchFilter.all(event.searchText)));
  }
}
