import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:firestore_pantry_api/firestore_pantry_api.dart';
import 'package:the_pantry/app/app.dart';

Future main() async {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      final authRepository = AuthenticationRepository();
      final pantryApi =
          FirestorePantryApi(instance: FirebaseFirestore.instance);
      await authRepository.user.first;
      final pantryRepository = PantryRepository(pantryApi: pantryApi);
      runApp(
        App(
          authenticationRepository: authRepository,
          pantryRepository: pantryRepository,
        ),
      );
    },
    blocObserver: AppBlocObserver(),
  );
}

// class MyApp extends StatelessWidget {
//   // final AppRouter router;
//   final Repository repository;
//
//   MyApp({
//     Key? key,
//     required this.repository,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return RepositoryProvider.value(
//       value: repository,
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(
//             create: (_) => AppBloc(authRepository: repository.auth),
//           ),
//           BlocProvider(
//               create: (context) => PantryCubit(repository: repository)),
//         ],
//         child: AppView(),
//       ),
//     );
//   }
// }
//
// class AppView extends StatefulWidget {
//   const AppView({Key? key}) : super(key: key);
//
//   @override
//   State<AppView> createState() => _AppViewState();
// }
//
// class _AppViewState extends State<AppView> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // theme: Theme.of(context).copyWith(
//       //   primaryColor: AppTheme.blue,
//       // ),
//       theme: ThemeData(
//         brightness: Brightness.light,
//         colorScheme: ColorScheme.fromSeed(
//             seedColor: AppTheme.blue, secondary: AppTheme.redBrown),
//         fontFamily: 'Roboto',
//       ),
//       title: 'The Pantry',
//       //home: const AuthenticationWrapper(),
//       home: FlowBuilder<AppStatus>(
//         state: context.select((AppBloc bloc) => bloc.state.status),
//         onGeneratePages: onGenerateAppViewPages,
//       )
//       routes: {
//         WelcomeScreen.id: (context) => const WelcomeScreen(),
//         LoginScreen.id: (context) => LoginScreen(),
//         SignUpScreen.id: (context) => SignUpScreen(),
//         HomeScreen.id: (context) => const HomeScreen(),
//       },
//     );
//   }
// }
//
// class AuthenticationWrapper extends StatelessWidget {
//   const AuthenticationWrapper({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Check current state of user authentication
//     return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
//       switch (state.status) {
//         case AuthStatus.authenticated:
//           context.read<PantryCubit>().fetchPantryList();
//           return const HomeScreen();
//         default:
//           return const WelcomeScreen();
//       }
//     });
//   }
// }
