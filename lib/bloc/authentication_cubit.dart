import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:the_pantry/data/repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final Repository repository;

  AuthenticationCubit({required this.repository})
      : super(AuthenticationInitial());
}
