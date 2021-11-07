import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/src/provider.dart';
import 'package:the_pantry/screens/grocery_screen.dart';
import 'package:the_pantry/services/authentication_service.dart';
import '../constants.dart';
import '../widgets/scaffold_snackbar.dart';
import '../widgets/wide_button.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  static String id = 'login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  User? user;
  bool _isLoading = false;

  initState() {
    _auth.userChanges().listen((event) => setState(() => user = event));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      // appBar: AppBar(title: Text("Login Screen")),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 150.0,
                    child: Image.asset('assets/images/icon.png'),
                  ),
                ),
              ),
              SizedBox(height: 48.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: AppTheme.textFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
                controller: emailController,
              ),
              SizedBox(height: 8.0),
              TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  decoration: AppTheme.textFieldDecoration.copyWith(
                    hintText: 'Enter your password',
                  ),
                  controller: passwordController),
              SizedBox(height: 24.0),
              WideButton(
                color: AppTheme.blue,
                text: 'Login',
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final result =
                      await context.read<AuthenticationService>().signIn(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                  if (result == 'Signed in') {
                    Navigator.pushNamed(context, GroceryScreen.id);
                  } else if (result == 'user-not-found') {
                    ScaffoldSnackbar.of(context)
                        .show('No user found for that email.');
                  } else if (result == 'wrong-password') {
                    ScaffoldSnackbar.of(context)
                        .show('Wrong password provided for that user.');
                  } else {
                    ScaffoldSnackbar.of(context)
                        .show('Unexpected error... please try again.');
                    print(result);
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
