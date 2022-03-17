import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/bloc/pantry_cubit.dart';

import 'package:the_pantry/constants.dart';
import 'package:the_pantry/data/models/pantry_model.dart';
import 'dismissible_widget.dart';

/// A scrollable list of Expansion tiles
///
/// [DismissiblePantryList] is used to display a scrollable
/// list of [DismissibleWidgets] each containing a [_PantryTile],
/// one for each of the user's current pantry items
/// Items are grouped into Expansion tiles by category for easier navigation.

class DismissiblePantryList extends StatelessWidget {
  final List<PantryItem> displayItems;

  const DismissiblePantryList({required this.displayItems, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodTypes = List.of(FoodType.values)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, state) {
        if (state.status != PantryStatus.loaded) {
          return const CircularProgressIndicator(color: AppTheme.warmRed);
        }
        final pantryList = state.pantryList;
        return ListView.builder(
          itemCount: foodTypes.length,
          itemBuilder: (context, index) {
            final foodType = foodTypes[index];
            final items = pantryList.ofFoodType(foodType);
            return IgnorePointer(
              ignoring: items.isEmpty,
              child: ExpansionTile(
                title: Text(foodType.displayName),
                subtitle: Text(displayItemCount(items.length)),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return DismissibleWidget(
                        key: UniqueKey(),
                        item: item,
                        leftSwipeIcon: Icons.shopping_cart,
                        leftSwipeText: 'To Groceries',
                        leftSwipeColor: AppTheme.paleTeal,
                        rightSwipeIcon: Icons.delete_forever,
                        rightSwipeText: 'Delete',
                        rightSwipeColor: Colors.red,
                        child: _PantryTile(
                          item: item,
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            BlocProvider.of<PantryCubit>(context)
                                .deleteItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} deleted'),
                              ),
                            );
                          } else if (direction == DismissDirection.endToStart) {
                            BlocProvider.of<PantryCubit>(context)
                                .toggleGroceries(item, status: true);
                            return false;
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PantryTile extends StatelessWidget {
  final PantryItem item;

  const _PantryTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: item.inGroceryList
          ? const Icon(Icons.shopping_cart, color: AppTheme.paleBlue)
          : null,
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
        onChanged: (String? newAmount) {
          if (newAmount != null) {
            BlocProvider.of<PantryCubit>(context).changeAmount(item, newAmount);
          }
        },
      ),
    );
  }
}

String displayItemCount(int numItems) {
  switch (numItems) {
    case 0:
      return 'no items';
    case 1:
      return '1 item';
    default:
      return '$numItems items';
  }
}
