part of 'search_cubit.dart';

enum SearchStatus { initial, loading, success, failure }
enum SearchTarget { userHistory, foodRepository, all }

class SearchState extends Equatable {
  final SearchStatus status;
  final SearchTarget target;
  final String searchText;
  // List of items from the search repository
  final List<PantryItem> items;
  // List of items user currently or previously entered
  final List<PantryItem> userItems;

  const SearchState({
    this.status = SearchStatus.initial,
    this.target = SearchTarget.all,
    this.searchText = '',
    this.items = const [],
    this.userItems = const [],
  });

  Iterable<PantryItem> get matchedItems {
    switch (target) {
      case SearchTarget.all:
        return _applyFilter((userItems + items).toSet().toList());
      case SearchTarget.userHistory:
        return _applyFilter(userItems);
      default:
        return _applyFilter(items);
    }
  }

  bool _matchesText(PantryItem item) {
    if (searchText.isEmpty) return true;
    return item.name.toLowerCase().contains(searchText.toLowerCase());
  }

  Iterable<PantryItem> _applyFilter(Iterable<PantryItem> items) {
    return items.where(_matchesText);
  }

  @override
  List<Object> get props => [status, searchText, target, items, userItems];

  SearchState copyWith({
    SearchStatus? status,
    String? searchText,
    SearchTarget? target,
    List<PantryItem>? items,
    List<PantryItem>? userItems,
  }) {
    return SearchState(
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      target: target ?? this.target,
      items: items ?? this.items,
      userItems: userItems ?? this.userItems,
    );
  }
}
