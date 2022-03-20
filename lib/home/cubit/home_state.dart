part of 'home_cubit.dart';

enum HomeTab { grocery, pantry }

class HomeState extends Equatable {
  final HomeTab tab;

  const HomeState({this.tab = HomeTab.grocery});

  @override
  List<Object> get props => [tab];
}
