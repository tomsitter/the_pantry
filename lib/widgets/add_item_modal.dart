import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/grocery_cart.dart';

import '../constants.dart';

class AddItemModal extends StatelessWidget {
  final textController = TextEditingController();

  AddItemModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Add item',
                style: TextStyle(color: AppTheme.paleTeal, fontSize: 24.0),
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
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppTheme.paleTeal),
              ),
              onPressed: () {
                Provider.of<GroceryCart>(context, listen: false)
                    .addItem(textController.text);
                Navigator.pop(context);
                // addItemCallback(textController.text);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
