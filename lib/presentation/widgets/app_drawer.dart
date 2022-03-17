import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../screens/welcome_screen.dart';

class AppDrawer extends StatelessWidget {
  final Color color;

  const AppDrawer({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! Authenticated) {
          Navigator.pushNamed(context, WelcomeScreen.id);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        String email = "Not authenticated";
        if (state is Authenticated) {
          email = state.user.email ?? "No email found";
        }
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(""),
                accountEmail: Text(email),
                decoration: BoxDecoration(
                  color: color,
                ),
              ),
              ListTile(
                  title: const Text('Logout'),
                  onTap: () =>
                      context.read<AuthBloc>().add(SignOutRequested())),
            ],
          ),
        );
      }),
    );
  }
}
