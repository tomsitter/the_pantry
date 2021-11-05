import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/grocery_cart.dart';
import 'package:the_pantry/widgets/grocery_list.dart';

import '../constants.dart';
import '../widgets/add_item_modal.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({Key? key}) : super(key: key);

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.paleTeal,
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => AddItemModal(),
        ),
        child: const Icon(Icons.add),
      ),
      // ),
      //     ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 64.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingActionButton(
                    onPressed: () {},
                    elevation: 5.0,
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.shopping_basket,
                        color: AppTheme.paleTeal, size: 40.0),
                  ),
                  const SizedBox(height: 32.0),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'My grocery list',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${Provider.of<GroceryCart>(context).count} Items',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 8.0, right: 8.0, bottom: 88.0),
                  child: GroceryList(),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.paleTeal,
    );
  }
}
