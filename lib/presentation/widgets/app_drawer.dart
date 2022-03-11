import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/data/services/authentication_service.dart';
import '../screens/welcome_screen.dart';

class AppDrawer extends StatelessWidget {
  final Color color;

  const AppDrawer({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    String displayName = 'No username';
    String email = 'No email';
    if (user != null) {
      displayName = user.displayName ?? displayName;
      email = user.email ?? email;
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(displayName),
            accountEmail: Text(email),
            decoration: BoxDecoration(
              color: color,
            ),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              final AuthenticationService user =
                  Provider.of<AuthenticationService>(context, listen: false);
              user.signOut();
              // Provider.of<PantryList>(context).clear();
              Navigator.pushNamed(context, WelcomeScreen.id);
            },
          ),
        ],
      ),
    );
  }
}
