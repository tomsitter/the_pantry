part of 'pantry_overview_bloc.dart';

enum PantryOverviewStatus { initial, loading, success, failure }

class PantryOverviewState extends Equatable {
  final PantryOverviewStatus status;
  final bool isGroceryScreen;
  final List<PantryItem> items;
  final PantryFilter filter;
  final PantryItem? lastDeletedItem;
  final String? errorMessage;

  const PantryOverviewState({
    this.status = PantryOverviewStatus.initial,
    required this.isGroceryScreen,
    this.items = const [],
    this.filter = PantryFilter.allItems,
    this.lastDeletedItem,
    this.errorMessage,
  });

  Iterable<PantryItem> get filteredItems =>
      filter.applyAll(items).toList()..sort((a, b) => a.name.compareTo(b.name));

  PantryOverviewState copyWith(
      {PantryOverviewStatus? status,
      bool? isGroceryScreen,
      List<PantryItem>? items,
      PantryFilter? filter,
      PantryItem? lastDeletedItem,
      String? errorMessage}) {
    return PantryOverviewState(
      status: status ?? this.status,
      isGroceryScreen: isGroceryScreen ?? this.isGroceryScreen,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      lastDeletedItem: lastDeletedItem ?? this.lastDeletedItem,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, isGroceryScreen, items, filter, lastDeletedItem, errorMessage];
}
