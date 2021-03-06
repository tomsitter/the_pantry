import 'package:authentication_repository/authentication_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/app/app.dart';
import 'package:the_pantry/theme/theme.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required AuthenticationRepository authenticationRepository,
    required FoodRepository foodRepository,
    required PantryRepository pantryRepository,
  })  : _authenticationRepository = authenticationRepository,
        _foodRepository = foodRepository,
        _pantryRepository = pantryRepository,
        super(key: key);

  final AuthenticationRepository _authenticationRepository;
  final FoodRepository _foodRepository;
  final PantryRepository _pantryRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider.value(
          value: _foodRepository,
        ),
        RepositoryProvider.value(
          value: _pantryRepository,
        )
      ],
      child: BlocProvider(
        create: (_) => AppBloc(
          authRepository: _authenticationRepository,
        ),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomTheme.light,
      debugShowCheckedModeBanner: false,
      home: FlowBuilder<AppStatus>(
        state: context.select((AppBloc bloc) => bloc.state.status),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
