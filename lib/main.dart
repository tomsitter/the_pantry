import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/auth_repository.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/pantry_cubit.dart';
import 'data/repositories/firestore_repository.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/registration_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'data/services/firestore_service.dart';
import 'constants.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(
      repository: Repository(
        db: FirestoreService(firestore: FirebaseFirestore.instance),
        auth: AuthRepository(firebaseAuth: FirebaseAuth.instance),
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRepository: repository.auth),
          ),
          BlocProvider(
              create: (context) => PantryCubit(repository: repository)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // theme: Theme.of(context).copyWith(
          //   primaryColor: AppTheme.blue,
          // ),
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.blue, secondary: AppTheme.redBrown),
            fontFamily: 'Roboto',
          ),
          title: 'The Pantry',
          home: const WelcomeScreen(),
          routes: {
            WelcomeScreen.id: (context) => const WelcomeScreen(),
            LoginScreen.id: (context) => LoginScreen(),
            RegistrationScreen.id: (context) => RegistrationScreen(),
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
      BlocProvider.of<PantryCubit>(context).fetchPantryList();
      return const HomeScreen();
    }
    return const WelcomeScreen();
  }
}
