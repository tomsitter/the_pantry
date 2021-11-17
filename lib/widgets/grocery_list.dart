import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/services/firestore_service.dart';

import '../constants.dart';
import 'dismissible_widget.dart';

class DismissibleGroceryList extends StatelessWidget {
  DismissibleGroceryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    UserData userData = context.watch<UserData>();
    final groceryList = userData.groceryList;
    FirestoreService db = context.read<FirestoreService>();

    if (user == null) {
      return const CircularProgressIndicator(color: AppTheme.warmRed);
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          final item = groceryList.items[index];
          return DismissibleWidget(
            item: item,
            altListIcon: Icons.home,
            // swipe left to delete
            deleteDirection: DismissibleWidget.left,
            child: _GroceryTile(
              item: item,
              checkboxCallback: (bool? checkboxState) {
                groceryList.toggle(item);
                db.updateUserData(user, userData);
              },
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                groceryList.delete(item);

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} deleted')));
              } else if (direction == DismissDirection.startToEnd) {
                // Tranfer item to pantry
                userData.transferItemFromGroceryToPantry(item);
                db.updateUserData(user, userData);
              }
              db.updateUserData(user, userData);
            },
          );
        },
        itemCount: groceryList.count,
      );
    }
  }
}

class _GroceryTile extends StatelessWidget {
  final GroceryItem item;
  final Function(bool?) checkboxCallback;

  const _GroceryTile(
      {Key? key, required this.item, required this.checkboxCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        item.name,
        style: TextStyle(
            decoration: item.isSelected ? TextDecoration.lineThrough : null),
      ),
      value: item.isSelected,
      onChanged: checkboxCallback,
    );
  }
}
