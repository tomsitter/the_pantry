import 'package:equatable/equatable.dart';
import 'package:pantry_repository/pantry_repository.dart';

class SearchFilter extends Equatable {
  final String searchText;

  static const allItems = SearchFilter(searchText: '');

  const SearchFilter({
    required this.searchText,
  });

  const SearchFilter._({searchText}) : searchText = searchText ?? "";

  bool apply(PantryItem item) {
    return matchesText(item, searchText);
  }

  bool matchesText(PantryItem item, String searchText) {
    if (searchText.isEmpty) return true;
    return item.name.toLowerCase().contains(searchText.toLowerCase());
  }

  Iterable<PantryItem> applyAll(Iterable<PantryItem> items) {
    return items.where(apply);
  }

  @override
  List<Object?> get props => [searchText];
}
