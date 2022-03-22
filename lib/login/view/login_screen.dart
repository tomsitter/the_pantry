import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/login/login.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: LoginScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(
            context.read<AuthenticationRepository>(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 150.0,
                    child: Image.asset('assets/images/icon.png'),
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
