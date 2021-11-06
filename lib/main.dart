import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/screens/grocery_screen.dart';
import 'package:the_pantry/screens/login_screen.dart';
import 'package:the_pantry/screens/registration_screen.dart';
import 'package:the_pantry/screens/welcome_screen.dart';

import 'models/grocery_cart.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(MyApp(isAuth: false));
    } else {
      runApp(MyApp(isAuth: true));
    }
  });
}

class MyApp extends StatelessWidget {
  final bool isAuth;
  const MyApp({Key? key, required this.isAuth}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroceryCart(<GroceryItem>[]),
      child: MaterialApp(
        title: 'The Pantry',
        initialRoute: isAuth ? GroceryScreen.id : WelcomeScreen.id,
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
