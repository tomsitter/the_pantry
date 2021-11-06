import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../constants.dart';
import '../utils/scaffold_snackbar.dart';
import '../widgets/wide_button.dart';
import 'grocery_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email = '';
  String password = '';
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
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: AppTheme.textFieldDecoration
                    .copyWith(hintText: 'Enter your email'),
                onChanged: (value) => email = value,
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
                onChanged: (value) => password = value,
              ),
              SizedBox(
                height: 8.0,
              ),
              WideButton(
                  color: AppTheme.darkBlue,
                  text: 'Register',
                  onPressed: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        Navigator.pushNamed(context, GroceryScreen.id);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        ScaffoldSnackbar.of(context)
                            .show('The password provided too weak');
                        print(e);
                      } else if (e.code == 'email-already-in-use') {
                        ScaffoldSnackbar.of(context)
                            .show('An account already exists for that email');
                        print(e);
                      }
                    } catch (e) {
                      print(e);
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
