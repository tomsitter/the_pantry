import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/services/firestore_service.dart';

import '../constants.dart';

class GroceryList extends StatelessWidget {
  final db = FirestoreService();

  GroceryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = context.read<User>();

    return StreamBuilder<UserData>(
        stream: db.streamUserData(user),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data!;
            return ListView.builder(
              itemBuilder: (context, index) {
                final item = userData.items[index];
                return Dismissible(
                  key: Key(item.name),
                  onDismissed: (direction) {
                    userData.deleteItem(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name} deleted')));
                  },
                  background: Container(color: AppTheme.warmRed),
                  child: _GroceryTile(
                    name: item.name,
                    isChecked: item.isSelected,
                    checkboxCallback: (bool? checkboxState) {
                      userData.toggleItem(item);
                      db.updateUserData(user, userData);
                    },
                  ),
                );
              },
              itemCount: userData.count,
            );
          } else {
            return Text('Could not get user data');
          }
        });
  }
}

class _GroceryTile extends StatelessWidget {
  final bool isChecked;
  final String name;
  final Function(bool?) checkboxCallback;

  const _GroceryTile(
      {Key? key,
      required this.isChecked,
      required this.name,
      required this.checkboxCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        name,
        style: TextStyle(
            decoration: isChecked ? TextDecoration.lineThrough : null),
      ),
      value: isChecked,
      onChanged: checkboxCallback,
    );
  }
}
