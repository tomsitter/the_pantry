part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchTextChanged extends SearchEvent {
  final String searchText;

  const SearchTextChanged(this.searchText);

  @override
  List<Object?> get props => [searchText];
}

class SearchFilterChanged extends SearchEvent {
  final SearchFilter filter;
  final String searchText;

  const SearchFilterChanged({required this.filter, searchText})
      : searchText = searchText ?? "";

  @override
  List<Object> get props => [filter, searchText];
}
