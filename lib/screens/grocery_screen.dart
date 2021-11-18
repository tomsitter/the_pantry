import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/widgets/dismissible_grocery_list.dart';

import '../widgets/add_item_modal.dart';

class GroceryScreen extends StatefulWidget {
  static String id = 'grocery_screen';
  final Color color;
  const GroceryScreen({required this.color, Key? key}) : super(key: key);

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  List<GroceryItem> _foundItems = [];
  TextEditingController searchController = TextEditingController();

  // This function is called whenever the text field changes
  void _runFilter(List<GroceryItem> items, String enteredKeyword) {
    List<GroceryItem> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = items;
    } else {
      results = items
          .where((item) =>
              item.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = context.watch<UserData>();
    _runFilter(userData.groceryList.items, searchController.text);
    return Scaffold(
      backgroundColor: widget.color,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    '${userData.groceryList.count} Items',
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 32.0),
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      controller: searchController,
                      onChanged: (value) =>
                          _runFilter(userData.groceryList.items, value),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        labelText: 'Search',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        suffixIcon: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
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
                  child: DismissibleGroceryList(displayItems: _foundItems),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(widget.color),
        ),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) =>
              AddItemModal(itemList: userData.groceryList, color: widget.color),
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
