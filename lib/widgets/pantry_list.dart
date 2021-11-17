import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/services/firestore_service.dart';

import '../constants.dart';
import 'dismissible_widget.dart';

class DismissiblePantryList extends StatelessWidget {
  DismissiblePantryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    UserData userData = context.watch<UserData>();
    final pantryList = userData.pantryList;
    FirestoreService db = context.read<FirestoreService>();

    if (user == null) {
      return const CircularProgressIndicator(color: AppTheme.warmRed);
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          final item = pantryList.items[index];
          return DismissibleWidget(
            item: item,
            altListIcon: Icons.shopping_cart,
            // swipe left to delete
            deleteDirection: DismissibleWidget.right,
            child: _PantryTile(
              item: item,
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                pantryList.delete(item);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} deleted')));
              } else if (direction == DismissDirection.endToStart) {
                userData.transferItemFromPantryToGrocery(item);
                db.updateUserData(user, userData);
              }
              db.updateUserData(user, userData);
            },
          );
        },
        itemCount: pantryList.count,
      );
    }
  }
}

class _PantryTile extends StatelessWidget {
  final PantryItem item;

  const _PantryTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('Added ${item.daysAgo()}'),
    );
  }
}
