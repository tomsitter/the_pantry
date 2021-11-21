import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/src/provider.dart';
import 'package:the_pantry/services/authentication_service.dart';
import '../constants.dart';
import '../widgets/scaffold_snackbar.dart';
import '../widgets/wide_button.dart';
import 'home/home.dart';

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

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
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
                  hintText: 'Enter your email or username',
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
                    Navigator.pushNamed(context, HomeScreen.id);
                  } else {
                    ScaffoldSnackbar.of(context).show(result);
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
