part of 'pantry_overview_bloc.dart';

abstract class PantryOverviewEvent extends Equatable {
  const PantryOverviewEvent();

  @override
  List<Object> get props => [];
}

class PantryOverviewSubscriptionRequested extends PantryOverviewEvent {
  const PantryOverviewSubscriptionRequested();
}

class PantryOverviewGroceryToggled extends PantryOverviewEvent {
  final PantryItem item;
  final bool isChecked;

  const PantryOverviewGroceryToggled({
    required this.item,
    required this.isChecked,
  });

  @override
  List<Object> get props => [item, isChecked];
}

class PantryOverviewAmountChanged extends PantryOverviewEvent {
  final PantryItem item;
  final String amount;

  const PantryOverviewAmountChanged({
    required this.item,
    required this.amount,
  });

  @override
  List<Object> get props => [item, amount];
}

class PantryOverviewMoveBetweenLists extends PantryOverviewEvent {
  final PantryItem item;
  final bool inGroceryList;

  const PantryOverviewMoveBetweenLists({
    required this.item,
    required this.inGroceryList,
  });

  @override
  List<Object> get props => [item, inGroceryList];
}

class PantryOverviewItemDeleted extends PantryOverviewEvent {
  final PantryItem item;

  const PantryOverviewItemDeleted(this.item);

  @override
  List<Object> get props => [item];
}

class PantryOverviewUndoDeletionRequested extends PantryOverviewEvent {
  const PantryOverviewUndoDeletionRequested();
}

class PantryOverviewFilterChanged extends PantryOverviewEvent {
  final PantryFilter filter;
  final String searchText;

  const PantryOverviewFilterChanged({required this.filter, searchText})
      : searchText = searchText ?? "";

  @override
  List<Object> get props => [filter, searchText];
}
