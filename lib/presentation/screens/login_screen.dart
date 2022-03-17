import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/constants.dart';
import 'package:the_pantry/presentation/widgets/auth_text_field.dart';
import '../../bloc/auth_bloc.dart';
import '../widgets/scaffold_snackbar.dart';
import '../widgets/wide_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushNamed(context, HomeScreen.id);
        }

        if (state is AuthError) {
          ScaffoldSnackbar.of(context).show(state.error);
        }

        if (state is AuthLoading) {
          ScaffoldSnackbar.of(context).show("Logging in");
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(height: 48.0),
              AuthTextField.email(
                  hintText: 'Enter your email', controller: emailController),
              const SizedBox(height: 8.0),
              AuthTextField.password(
                  hintText: 'Enter your password',
                  controller: passwordController),
              const SizedBox(height: 24.0),
              WideButton(
                color: AppTheme.blue,
                text: 'Login',
                onPressed: () async {
                  context.read<AuthBloc>().add(SignInRequested(
                      emailController.text, passwordController.text));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
