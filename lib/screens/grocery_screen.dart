import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/services/firestore_service.dart';
import 'package:the_pantry/widgets/app_drawer.dart';
import 'package:the_pantry/widgets/grocery_list.dart';

import '../constants.dart';
import '../widgets/add_item_modal.dart';

class GroceryScreen extends StatelessWidget {
  static String id = 'grocery_screen';
  const GroceryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserData userData = context.watch<UserData>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.blue,
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => AddItemModal(),
        ),
        child: const Icon(Icons.add),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My grocery list',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${userData.count} Items',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {},
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(10.0),
                  color: Colors.white,
                  child: const Icon(Icons.shopping_basket,
                      color: AppTheme.blue, size: 40.0),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
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
                  child: GroceryList(),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.blue,
    );
  }
}
