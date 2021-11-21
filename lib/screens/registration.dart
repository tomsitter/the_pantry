import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/src/provider.dart';
import 'package:the_pantry/services/authentication_service.dart';
import 'package:username_generator/username_generator.dart';

import '../constants.dart';
import '../widgets/scaffold_snackbar.dart';
import '../widgets/wide_button.dart';
import 'home/home.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController =
      TextEditingController(text: UsernameGenerator().generateRandom());
  bool _isLoading = false;

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
                textAlign: TextAlign.center,
                decoration: AppTheme.textFieldDecoration
                    .copyWith(hintText: 'Choose a username'),
                controller: displayNameController,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: AppTheme.textFieldDecoration
                    .copyWith(hintText: 'Enter your email'),
                controller: emailController,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: AppTheme.textFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
                controller: passwordController,
              ),
              SizedBox(
                height: 8.0,
              ),
              WideButton(
                  color: AppTheme.darkBlue,
                  text: 'Register',
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    String displayName = displayNameController.text.trim();
                    final result =
                        await context.read<AuthenticationService>().signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              displayName: displayName.isNotEmpty
                                  ? displayName
                                  : UsernameGenerator().generateRandom(),
                            );
                    if (result == 'Signed up') {
                      Navigator.pushNamed(context, HomeScreen.id);
                    } else if (result == 'weak-password') {
                      ScaffoldSnackbar.of(context)
                          .show('The password provided too weak');
                    } else if (result == 'email-already-in-use') {
                      print('email already in user');
                      ScaffoldSnackbar.of(context)
                          .show('An account already exists for that email');
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
