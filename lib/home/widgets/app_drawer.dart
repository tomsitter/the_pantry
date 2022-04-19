import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/app/app.dart';
import 'package:the_pantry/constants.dart' as constants;
import 'package:the_pantry/pantry_overview/bloc/pantry_overview_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
            accountName: const Text(''),
            accountEmail: Text(
              context.select((AppBloc bloc) => bloc.state.user.email),
              style: const TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: color,
            ),
          ),
          ListTile(
              title: const Text('Share your Grocery List'),
              onTap: () {
                String emailBody =
                    context.read<PantryOverviewBloc>().pantryHTMLItems;
                _launchURL(
                    'mailto:?subject=My%20Grocery%20List&body=$emailBody');
              }),
          const Divider(),
          ListTile(
              title: const Text('Logout'),
              onTap: () => context.read<AppBloc>().add(AppLogoutRequested())),
          const Divider(),
          ListTile(
              title: const Text('Privacy Policy'),
              onTap: () => _launchURL(constants.privacyURL)),
          ListTile(
              title: const Text('Terms of Use'),
              onTap: () => _launchURL(constants.termsURL)),
        ],
      ),
    );
  }
}

void _launchURL(String url) async {
  if (!await launch(url)) throw 'Could not launch $url';
}
