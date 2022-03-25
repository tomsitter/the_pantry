import 'package:equatable/equatable.dart';
import 'package:pantry_repository/pantry_repository.dart';

enum SearchFilterType {
  all,
  none,
}

class SearchFilter extends Equatable {
  final SearchFilterType filter;
  final String searchText;

  static const noItems =
      SearchFilter(filter: SearchFilterType.none, searchText: '');

  const SearchFilter({
    required this.filter,
    required this.searchText,
  });

  const SearchFilter._({required this.filter, searchText})
      : searchText = searchText ?? "";

  const SearchFilter.all([String searchText = ""])
      : this._(filter: SearchFilterType.all, searchText: searchText);

  const SearchFilter.none([String searchText = ""])
      : this._(filter: SearchFilterType.none, searchText: searchText);

  bool apply(PantryItem item) {
    switch (filter) {
      case SearchFilterType.all:
        return matchesText(item, searchText);
      case SearchFilterType.none:
        return false;
      default:
        return true;
    }
  }

  bool matchesText(PantryItem item, String searchText) {
    if (searchText.isEmpty) return true;
    return item.name.toLowerCase().contains(searchText.toLowerCase());
  }

  Iterable<PantryItem> applyAll(Iterable<PantryItem> items) {
    return items.where(apply);
  }

  @override
  List<Object?> get props => [filter, searchText];
}
