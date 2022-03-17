part of 'pantry_cubit.dart';

enum PantryStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class PantryState extends Equatable {
  final PantryList pantryList;
  final PantryStatus status;
  final String error;

  const PantryState(
      {required this.status, required this.pantryList, required this.error});

  factory PantryState.initial() {
    return PantryState(
      pantryList: PantryList(items: []),
      status: PantryStatus.initial,
      error: '',
    );
  }

  PantryState copyWith(
      {PantryList? pantryList, PantryStatus? status, String? error}) {
    return PantryState(
      pantryList: pantryList ?? this.pantryList,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [pantryList, status, error];
}
