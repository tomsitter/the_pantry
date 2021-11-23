import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:the_pantry/models/pantry_model.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/services/firestore_service.dart';
import 'package:the_pantry/constants.dart';
import 'package:the_pantry/widgets/dismissible_widget.dart';

class DismissiblePantryList extends StatelessWidget {
  final List<PantryItem> displayItems;

  const DismissiblePantryList({required this.displayItems, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    UserData userData = context.watch<UserData>();
    final pantryList = userData.pantryList;
    FirestoreService db = context.read<FirestoreService>();

    if (user == null) {
      return const CircularProgressIndicator(color: AppTheme.warmRed);
    } else {
      var foodTypes = pantryList.uniqueFoodTypes();
      print(foodTypes);
      return ListView.builder(
        itemCount: foodTypes.length,
        itemBuilder: (context, index) {
          final foodType = foodTypes[index];
          final items = pantryList.ofFoodType(foodType);
          return ExpansionTile(
            title: Text(describeEnum(foodType)),
            subtitle: items.length > 1
                ? Text('${items.length} items')
                : Text('1 item'),
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return DismissibleWidget(
                      item: item,
                      altDismissIcon: Icons.shopping_cart,
                      altDismissText: 'To Groceries',
                      // swipe left to delete
                      deleteDirection: DismissibleWidget.right,
                      child: _PantryTile(
                        item: item,
                        onAmountChanged: (String? newAmount) {
                          pantryList.updateItemAmount(item, newAmount!);
                          db.updateUserData(user, userData);
                        },
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          pantryList.delete(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item.name} deleted')));
                        } else if (direction == DismissDirection.endToStart) {
                          userData.transferFromPantryToGrocery(item);
                          db.updateUserData(user, userData);
                        }
                        db.updateUserData(user, userData);
                      },
                    );
                  }),
            ],
          );
        },
      );
    }
  }
}

class _PantryTile extends StatelessWidget {
  final PantryItem item;
  final void Function(String?) onAmountChanged;

  const _PantryTile(
      {Key? key, required this.item, required this.onAmountChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('Added ${item.daysAgo()}'),
      trailing: DropdownButton<String>(
        value: describeEnum(item.amount),
        items: amountMap.keys.map<DropdownMenuItem<String>>((key) {
          return DropdownMenuItem<String>(
            value: key,
            child: Text(key),
          );
        }).toList(),
        onChanged: onAmountChanged,
      ),
    );
  }
}
