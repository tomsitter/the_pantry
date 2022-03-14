import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/bloc/pantry_list_cubit.dart';

import 'package:the_pantry/constants.dart';
import 'package:the_pantry/data/models/pantry_model.dart';
import 'dismissible_widget.dart';

class DismissiblePantryList extends StatelessWidget {
  final List<PantryItem> displayItems;

  const DismissiblePantryList({required this.displayItems, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodTypes = List.of(FoodType.values)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return BlocBuilder<PantryListCubit, PantryListState>(
      builder: (context, state) {
        if (state is! PantryListLoaded) {
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
                        altDismissIcon: Icons.shopping_cart,
                        altDismissText: 'To Groceries',
                        // swipe left to delete
                        deleteDirection: DismissibleWidget.right,
                        child: _PantryTile(
                          item: item,
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            BlocProvider.of<PantryListCubit>(context)
                                .deleteItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} deleted'),
                              ),
                            );
                          } else if (direction == DismissDirection.endToStart) {
                            BlocProvider.of<PantryListCubit>(context)
                                .toggleGroceries(item, status: true);
                            return false;
                          }
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
            BlocProvider.of<PantryListCubit>(context)
                .changeAmount(item, newAmount);
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