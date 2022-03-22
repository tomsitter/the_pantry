import 'dart:async';

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

  PantryOverviewBloc(
      {required PantryRepository pantryRepository,
      required AuthenticationRepository authRepository})
      : _pantryRepository = pantryRepository,
        _authRepository = authRepository,
        super(const PantryOverviewState()) {
    _pantryRepository.fetchPantryItems(_authRepository.currentUser.id);
    on<PantryOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<PantryOverviewMoveBetweenLists>(_onMoveBetweenLists);
    on<PantryOverviewFilterChanged>(_onFilterChanged);
    on<PantryOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<PantryOverviewItemDeleted>(_onItemDeleted);
    on<PantryOverviewGroceryToggled>(_onGroceryToggled);
    on<PantryOverviewAmountChanged>(_onAmountChanged);
  }

  Future<void> _onSubscriptionRequested(
    PantryOverviewSubscriptionRequested event,
    Emitter<PantryOverviewState> emit,
  ) async {
    emit(state.copyWith(status: PantryOverviewStatus.loading));

    await emit.forEach<List<PantryItem>>(
      _pantryRepository.getPantryItems(),
      onData: (items) => state.copyWith(
        status: PantryOverviewStatus.success,
        items: items,
      ),
      onError: (_, __) => state.copyWith(
        status: PantryOverviewStatus.failure,
      ),
    );
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
      await _pantryRepository.savePantryItem(user.id, newItem);
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
      await _pantryRepository.savePantryItem(user.id, item!);
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
      await _pantryRepository.deletePantryItem(user.id, event.item);
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
      await _pantryRepository.savePantryItem(user.id, newItem);
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
      await _pantryRepository.savePantryItem(user.id, newItem);
    }
  }
}
