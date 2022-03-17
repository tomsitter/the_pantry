import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/bloc/pantry_cubit.dart';

import 'package:the_pantry/data/models/pantry_model.dart';
import 'package:the_pantry/constants.dart';
import '../widgets/dismissible_widget.dart';

class DismissibleGroceryList extends StatelessWidget {
  final List<PantryItem> displayItems;

  const DismissibleGroceryList({required this.displayItems, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return Column(
              children: [
                DismissibleWidget(
                  key: UniqueKey(),
                  item: item,
                  leftSwipeIcon: Icons.delete_forever,
                  leftSwipeText: 'Delete',
                  leftSwipeColor: Colors.red,
                  rightSwipeIcon: Icons.home,
                  rightSwipeText: 'To Pantry',
                  rightSwipeColor: AppTheme.paleTeal,
                  child: _GroceryTile(
                    item: item,
                    checkboxCallback: (bool? checkboxState) {
                      context.read<PantryCubit>().toggleChecked(item);
                    },
                  ),
                  confirmDismiss: (direction) async {
                    // delete direction
                    if (direction == DismissDirection.endToStart) {
                      context.read<PantryCubit>().deleteItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.name} deleted')));
                      return true;
                      // to pantry direction
                    } else if (direction == DismissDirection.startToEnd) {
                      context
                          .read<PantryCubit>()
                          .toggleGroceries(item, status: false);
                      return false;
                    }
                    return null;
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
