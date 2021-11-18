import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/services/firestore_service.dart';

import '../models/user_data.dart';

/// [AddItemModal] is a screen that pops up from the bottom of the screen
/// to allow users to add a new item to either the pantry or the grocery lists
///
/// It requires a reference to the list that it will add to (either [GroceryList]
/// or [PantryList], and a color to match that of the parent screen
class AddItemModal extends StatelessWidget {
  final textController = TextEditingController();
  final AbstractItemList itemList;
  final Color color;

  AddItemModal({Key? key, required this.itemList, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = context.read<FirestoreService>();
    UserData userData = Provider.of<UserData>(context);
    User user = Provider.of<User>(context);

    return Material(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Add item',
                style: TextStyle(color: color, fontSize: 24.0),
              ),
            ),
            TextField(
              controller: textController,
              textAlign: TextAlign.center,
              autofocus: true,
            ),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(horizontal: 64.0)),
                backgroundColor: MaterialStateProperty.all<Color>(color),
              ),
              onPressed: () {
                itemList.add(textController.text);
                db.updateUserData(user, userData);
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
