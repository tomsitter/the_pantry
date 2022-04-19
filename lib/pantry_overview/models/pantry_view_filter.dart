import 'package:equatable/equatable.dart';
import 'package:pantry_repository/pantry_repository.dart';

enum PantryFilterType {
  all,
  uncheckedOnly,
  checkedOnly,
  groceriesOnly,
  pantryOnly,
}

class PantryFilter extends Equatable {
  final PantryFilterType filter;
  final String searchText;

  static const allItems =
      PantryFilter(filter: PantryFilterType.all, searchText: '');

  const PantryFilter({
    required this.filter,
    required this.searchText,
  });

  bool get isGroceryFilter => filter == PantryFilterType.groceriesOnly;

  const PantryFilter._({required this.filter, searchText})
      : searchText = searchText ?? '';

  const PantryFilter.all([String searchText = ''])
      : this._(filter: PantryFilterType.all, searchText: searchText);

  const PantryFilter.groceriesOnly([String searchText = ''])
      : this._(filter: PantryFilterType.groceriesOnly, searchText: searchText);

  const PantryFilter.pantryOnly([String searchText = ''])
      : this._(filter: PantryFilterType.pantryOnly, searchText: searchText);

  bool apply(PantryItem item) {
    switch (filter) {
      case PantryFilterType.all:
        return matchesText(item, searchText);
      case PantryFilterType.groceriesOnly:
        return item.inGroceryList && matchesText(item, searchText);
      case PantryFilterType.pantryOnly:
        return !item.inGroceryList && matchesText(item, searchText);
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
