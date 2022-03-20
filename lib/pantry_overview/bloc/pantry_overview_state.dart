part of 'pantry_overview_bloc.dart';

enum PantryOverviewStatus { initial, loading, success, failure }

class PantryOverviewState extends Equatable {
  final PantryOverviewStatus status;
  final List<PantryItem> items;
  final PantryViewFilter filter;
  final PantryItem? lastDeletedItem;
  final String? errorMessage;

  const PantryOverviewState({
    this.status = PantryOverviewStatus.initial,
    this.items = const [],
    this.filter = PantryViewFilter.all,
    this.lastDeletedItem,
    this.errorMessage,
  });

  Iterable<PantryItem> get filteredItems => filter.applyAll(items);

  PantryOverviewState copyWith(
      {PantryOverviewStatus? status,
      List<PantryItem>? items,
      PantryViewFilter? filter,
      PantryItem? lastDeletedItem,
      String? errorMessage}) {
    return PantryOverviewState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      lastDeletedItem: lastDeletedItem ?? this.lastDeletedItem,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, filter, lastDeletedItem, errorMessage];
}
