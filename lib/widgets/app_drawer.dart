import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/screens/welcome_screen.dart';
import 'package:the_pantry/services/authentication_service.dart';
import 'package:the_pantry/services/firestore_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        // const DrawerHeader(
        //   decoration: BoxDecoration(
        //     color: AppTheme.redBrown,
        //   ),
        //   child: Text('Drawer Header'),
        // ),
        ListTile(
          title: const Text('Logout'),
          onTap: () async {
            context.read<AuthenticationService>().signOut();
            Navigator.pushNamed(context, WelcomeScreen.id);
          },
        ),
        ListTile(
          title: const Text('Save List'),
          onTap: () async {
            final user = context.read<User>();
            final userData = context.read<UserData>();
            context.read<FirestoreService>().updateUserData(user, userData);
          },
        ),
      ]),
    );
  }
}
