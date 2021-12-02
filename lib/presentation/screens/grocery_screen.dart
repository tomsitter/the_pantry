import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/bloc/pantry_list_cubit.dart';
import 'package:the_pantry/data/models/pantry_model.dart';
import 'package:the_pantry/presentation/widgets/dismissible_grocery_list.dart';

import '../../constants.dart';
import '../widgets/add_item_modal.dart';

class GroceryScreen extends StatefulWidget {
  static const String id = 'grocery_screen';
  final Color color;
  const GroceryScreen({required this.color, Key? key}) : super(key: key);

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
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
          .where(
            (item) => item.name.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
          )
          .toList();
    }

    // Refresh the UI
    setState(() {
      _foundItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    // PantryList pantryList = context.watch<PantryList>();
    return Scaffold(
      backgroundColor: widget.color,
      body: SafeArea(
        child: BlocBuilder<PantryListCubit, PantryListState>(
          builder: (context, state) {
            if (state is! PantryListLoaded) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.warmRed));
            }
            final pantryList = state.pantryList;
            _foundItems = pantryList.groceries;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${pantryList.countGroceries} Items',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 32.0),
                      Expanded(
                        child: TextField(
                          autofocus: false,
                          controller: searchController,
                          onChanged: (value) =>
                              _runFilter(pantryList.items, value),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            labelText: 'Search',
                            labelStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            suffixIcon:
                                const Icon(Icons.search, color: Colors.white),
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
            );
          },
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
              AddItemModal(inGroceryList: true, color: widget.color),
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
