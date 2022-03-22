import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/app/app.dart';

class AppDrawer extends StatelessWidget {
  final Color color;

  const AppDrawer({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(""),
            accountEmail: Text(
              context.select((AppBloc bloc) => bloc.state.user.email),
              style: TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: color,
            ),
          ),
          ListTile(
              title: const Text('Logout'),
              onTap: () => context.read<AppBloc>().add(AppLogoutRequested())),
        ],
      ),
    );
  }
}
