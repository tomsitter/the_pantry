import 'dart:async';
import 'dart:convert';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';

part 'pantry_overview_event.dart';
part 'pantry_overview_state.dart';

class PantryOverviewBloc
    extends Bloc<PantryOverviewEvent, PantryOverviewState> {
  final PantryRepository _pantryRepository;
  final AuthenticationRepository _authRepository;
  late final StreamSubscription<User> _userSubscription;
  late final StreamSubscription<List<PantryItem>> _pantrySubscription;

  // late final StreamSubscription<List<PantryItem>> _pantrySubscription;

  PantryOverviewBloc(
      {required PantryRepository pantryRepository,
      required AuthenticationRepository authRepository})
      : _pantryRepository = pantryRepository,
        _authRepository = authRepository,
        super(const PantryOverviewState()) {
    on<PantryOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<PantryOverviewMoveBetweenLists>(_onMoveBetweenLists);
    on<PantryOverviewFilterChanged>(_onFilterChanged);
    on<PantryOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<PantryOverviewItemDeleted>(_onItemDeleted);
    on<PantryOverviewGroceryToggled>(_onGroceryToggled);
    on<PantryOverviewAmountChanged>(_onAmountChanged);
    on<PantryOverviewPantryUpdated>(_onPantryUpdated);

    _pantrySubscription = _pantryRepository.pantryItems
        .listen((items) => add(PantryOverviewPantryUpdated(items)));

    _userSubscription = _authRepository.user
        .listen((user) => add(PantryOverviewSubscriptionRequested(user)));
  }

  String get pantryHTMLItems {
    // Get items sorted by category
    final List<PantryItem> items = state.filteredItems.toList();
    if (items.isEmpty) {
      return const HtmlEscape().convert('No grocery items');
    }

    String htmlBody = '';
    final List<FoodCategory> categories =
        items.map((item) => item.category).toSet().toList()..sort();
    for (final category in categories) {
      htmlBody += '\n${category.displayName}\n';
      htmlBody += '--------------\n';
      final categoryItems =
          items.where((item) => item.category == category).toList()..sort();
      for (final item in categoryItems) {
        htmlBody += '${item.name}\n';
      }
    }

    return const HtmlEscape().convert(htmlBody);
  }

  Future<void> _onSubscriptionRequested(
    PantryOverviewSubscriptionRequested event,
    Emitter<PantryOverviewState> emit,
  ) async {
    emit(state.copyWith(status: PantryOverviewStatus.loading));
    _pantryRepository.streamUserPantryItems(event.user.id);
  }

  Future<void> _onPantryUpdated(
    PantryOverviewPantryUpdated event,
    Emitter<PantryOverviewState> emit,
  ) async {
    emit(state.copyWith(
        status: PantryOverviewStatus.success, items: event.items));
  }

  Future<void> _onMoveBetweenLists(
    PantryOverviewMoveBetweenLists event,
    Emitter<PantryOverviewState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user.isEmpty) {
      emit(state.copyWith(status: PantryOverviewStatus.failure));
    } else {
      final newItem = event.item.copyWith(inGroceryList: event.inGroceryList);
      await _pantryRepository.saveItem(user.id, newItem);
    }
  }

  Future<void> _onFilterChanged(
    PantryOverviewFilterChanged event,
    Emitter<PantryOverviewState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onUndoDeletionRequested(
    PantryOverviewUndoDeletionRequested event,
    Emitter<PantryOverviewState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user.isEmpty || state.lastDeletedItem == null) {
      emit(state.copyWith(status: PantryOverviewStatus.failure));
    } else {
      final item = state.lastDeletedItem;
      emit(state.copyWith(lastDeletedItem: null));
      await _pantryRepository.saveItem(user.id, item!);
    }
  }

  Future<void> _onItemDeleted(
    PantryOverviewItemDeleted event,
    Emitter<PantryOverviewState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user.isEmpty) {
      emit(state.copyWith(status: PantryOverviewStatus.failure));
    } else {
      emit(state.copyWith(lastDeletedItem: event.item));
      await _pantryRepository.deleteItem(user.id, event.item);
    }
  }

  Future<void> _onGroceryToggled(
    PantryOverviewGroceryToggled event,
    Emitter<PantryOverviewState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user.isEmpty) {
      emit(state.copyWith(status: PantryOverviewStatus.failure));
    } else {
      final newItem = event.item.copyWith(isChecked: event.isChecked);
      await _pantryRepository.saveItem(user.id, newItem);
    }
  }

  Future<void> _onAmountChanged(
    PantryOverviewAmountChanged event,
    Emitter<PantryOverviewState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user.isEmpty) {
      emit(state.copyWith(status: PantryOverviewStatus.failure));
    } else {
      final newAmount = FoodAmount.fromString(event.amount);
      final newItem = event.item.copyWith(amount: newAmount);
      await _pantryRepository.saveItem(user.id, newItem);
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    _pantrySubscription.cancel();
    return super.close();
  }
}
