import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/widgets/grocery_list.dart';
import 'package:the_pantry/widgets/pantry_list.dart';

import '../widgets/add_item_modal.dart';

class PantryScreen extends StatelessWidget {
  static String id = 'pantry_screen';
  final Color color;

  const PantryScreen({required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserData userData = context.watch<UserData>();
    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Text(
                '${userData.pantryList.count} Items',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, top: 8.0, right: 8.0, bottom: 88.0),
                  child: DismissiblePantryList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
        ),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => AddItemModal(itemList: userData.pantryList),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Icon(Icons.add),
            Text('Add item'),
          ],
        ),
      ),
    );
  }
}
