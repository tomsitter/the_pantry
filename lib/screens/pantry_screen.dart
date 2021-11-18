import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/user_data.dart';
import 'package:the_pantry/widgets/dismissible_pantry_list.dart';

import '../widgets/add_item_modal.dart';

class PantryScreen extends StatefulWidget {
  static String id = 'pantry_screen';
  final Color color;

  const PantryScreen({required this.color, Key? key}) : super(key: key);

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  List<PantryItem> _foundItems = [];
  TextEditingController searchController = TextEditingController();

  // This function is called whenever the text field changes
  void _runFilter(List<PantryItem> items, String enteredKeyword) {
    List<PantryItem> results = [];
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
    _runFilter(userData.pantryList.items, searchController.text);
    return Scaffold(
      backgroundColor: widget.color,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  Text(
                    '${userData.pantryList.count} Items',
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 32.0),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) =>
                          _runFilter(userData.pantryList.items, value),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
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
                  child: DismissiblePantryList(displayItems: _foundItems),
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
              AddItemModal(itemList: userData.pantryList, color: widget.color),
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
