import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/grocery_model.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/services/firestore_service.dart';

import 'package:the_pantry/constants.dart';
import 'package:the_pantry/widgets/dismissible_widget.dart';

class DismissibleGroceryList extends StatelessWidget {
  final List<GroceryItem> displayItems;

  const DismissibleGroceryList({required this.displayItems, Key? key})
      : super(key: key);

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
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          return Column(
            children: [
              DismissibleWidget(
                key: UniqueKey(),
                item: item,
                altDismissIcon: Icons.home,
                altDismissText: 'To Pantry',
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
                    // Transfer item to pantry
                    userData.transferFromGroceryToPantry(item);
                    db.updateUserData(user, userData);
                  }
                  db.updateUserData(user, userData);
                },
              ),
              const Divider(),
            ],
          );
        },
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
      //dense: true,
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
