import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_pantry/bloc/pantry_list_cubit.dart';

import 'package:the_pantry/data/models/pantry_model.dart';
import 'package:the_pantry/data/services/firestore_service.dart';
import 'package:the_pantry/constants.dart';
import '../widgets/dismissible_widget.dart';

class DismissibleGroceryList extends StatelessWidget {
  final List<PantryItem> displayItems;

  const DismissibleGroceryList({required this.displayItems, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    FirestoreService db = context.read<FirestoreService>();
    return BlocBuilder<PantryListCubit, PantryListState>(
      builder: (context, state) {
        if (state is! PantryListLoaded) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.warmRed));
        }
        return ListView.builder(
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return Column(
              children: [
                DismissibleWidget(
                  key: UniqueKey(),
                  item: item,
                  altDismissIcon: Icons.home,
                  altDismissText: 'To Pantry',
                  // swipe left to delete
                  deleteDirection: DismissibleWidget.left,
                  child: _GroceryTile(
                    item: item,
                    checkboxCallback: (bool? checkboxState) {
                      BlocProvider.of<PantryListCubit>(context)
                          .toggleChecked(item);
                    },
                  ),
                  confirmDismiss: (direction) async {
                    // delete direction
                    if (direction == DismissDirection.endToStart) {
                      BlocProvider.of<PantryListCubit>(context)
                          .deleteItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.name} deleted')));
                      return true;
                      // to pantry direction
                    } else if (direction == DismissDirection.startToEnd) {
                      BlocProvider.of<PantryListCubit>(context)
                          .toggleGroceries(item, status: false);
                      return false;
                    }
                  },
                ),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

class _GroceryTile extends StatelessWidget {
  final PantryItem item;
  final Function(bool?) checkboxCallback;

  const _GroceryTile(
      {Key? key, required this.item, required this.checkboxCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      title: Text(
        item.name,
        style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null),
      ),
      value: item.isChecked,
      onChanged: checkboxCallback,
    );
  }
}