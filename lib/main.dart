import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/screens/grocery_screen.dart';
import 'package:the_pantry/screens/login_screen.dart';
import 'package:the_pantry/screens/registration_screen.dart';
import 'package:the_pantry/screens/welcome_screen.dart';
import 'package:the_pantry/services/authentication_service.dart';
import 'package:the_pantry/services/firestore_service.dart';

import 'models/user_data.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        StreamProvider<UserData>(
          create: (context) {
            final user = context.read<User>();
            return FirestoreService().streamUserData(user);
          },
          initialData: UserData([]),
        )
      ],
      child: MaterialApp(
        title: 'The Pantry',
        home: AuthenticationWrapper(),
        routes: {
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          GroceryScreen.id: (context) => const GroceryScreen(),
          RegistrationScreen.id: (context) => const RegistrationScreen(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return GroceryScreen();
    }
    return WelcomeScreen();
  }
}
