import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/grocery_cart.dart';

import '../constants.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryCart>(
      builder: (BuildContext context, groceryCart, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final item = groceryCart.items[index];
            return Dismissible(
              key: Key(item.name),
              onDismissed: (direction) {
                groceryCart.deleteItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} deleted')));
              },
              background: Container(color: AppTheme.warmRed),
              child: _GroceryTile(
                name: item.name,
                isChecked: item.isSelected,
                checkboxCallback: (bool? checkboxState) {
                  groceryCart.toggleItem(item);
                },
              ),
            );
          },
          itemCount: groceryCart.count,
        );
      },
    );
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
