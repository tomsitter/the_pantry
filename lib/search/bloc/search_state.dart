part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final SearchFilter filter;
  // List of items from the search repository
  final List<PantryItem> items;
  // List of items user currently or previously entered
  final List<PantryItem> userItems;

  const SearchState({
    this.status = SearchStatus.initial,
    this.filter = SearchFilter.noItems,
    this.items = const [],
    this.userItems = const [],
  });

  Iterable<PantryItem> get matchedItems => filter.applyAll(items);

  @override
  List<Object> get props => [status, filter, items, userItems];

  SearchState copyWith({
    SearchStatus? status,
    SearchFilter? filter,
    List<PantryItem>? items,
    List<PantryItem>? userItems,
  }) {
    return SearchState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      userItems: userItems ?? this.userItems,
    );
  }
}
