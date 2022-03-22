import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void setTab(int index) {
    HomeTab tab = index == 0 ? HomeTab.grocery : HomeTab.pantry;
    emit(HomeState(tab: tab));
  }
}
