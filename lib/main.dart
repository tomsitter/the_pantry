import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/bloc/authentication_cubit.dart';
import 'package:the_pantry/presentation/router.dart';

import 'bloc/add_item_cubit.dart';
import 'bloc/pantry_list_cubit.dart';
import 'data/repository.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/registration_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'data/services/authentication_service.dart';
import 'data/services/firestore_service.dart';
import 'data/models/pantry_model.dart';
import 'constants.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(
      repository: Repository(
        db: FirestoreService(),
        auth: AuthenticationService(FirebaseAuth.instance),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  // final AppRouter router;
  final Repository repository;

  MyApp({
    Key? key,
    required this.repository,
    // required this.router
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final pantryListCubit = PantryListCubit(repository: repository);

    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (context) {
            final auth = AuthenticationService(FirebaseAuth.instance);
            return auth.authStateChanges;
          },
          initialData: null,
        ),
        // StreamProvider<UserData>(
        //   create: (context) {
        //     final user = context.read<User>();
        //     return FirestoreService().streamUserData(user);
        //   },
        //   initialData: UserData(),
        // ),
        // ChangeNotifierProxyProvider<User?, PantryList>(
        //     lazy: false,
        //     create: (_) => PantryList(items: <PantryItem>[]),
        //     update: (_, user, pantryList) {
        //       if (user != null) {
        //         pantryListCubit.fetchPantryList();
        //       } else {
        //         return pantryList!;
        //       }
        //     }),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PantryListCubit>.value(
            value: pantryListCubit,
          ),
          BlocProvider<AddItemCubit>(
            create: (context) => AddItemCubit(
                repository: repository, pantryListCubit: pantryListCubit),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context).copyWith(
            primaryColor: AppTheme.blue,
          ),
          title: 'The Pantry',
          home: const AuthenticationWrapper(),
          routes: {
            WelcomeScreen.id: (context) => const WelcomeScreen(),
            LoginScreen.id: (context) => const LoginScreen(),
            RegistrationScreen.id: (context) => const RegistrationScreen(),
            HomeScreen.id: (context) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user != null) {
      return const HomeScreen();
    }
    return const WelcomeScreen();
  }
}
