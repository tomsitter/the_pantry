import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_api/pantry_api.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';

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
    List<FoodCategory> foodTypes =
        FoodCategory.categories.map((value) => FoodCategory(value)).toList();

    return BlocBuilder<PantryOverviewBloc, PantryOverviewState>(
      builder: (context, state) {
        final pantryList = state.items;
        return ListView.builder(
          itemCount: foodTypes.length,
          itemBuilder: (context, index) {
            final foodType = foodTypes[index];
            final items =
                pantryList.where((item) => item.category == foodType).toList();
            return IgnorePointer(
              ignoring: items.isEmpty,
              child: ExpansionTile(
                collapsedTextColor: items.isEmpty ? Colors.grey : Colors.black,
                textColor: Theme.of(context).secondaryHeaderColor,
                title: Text(foodType.displayName),
                subtitle: Text(displayItemCount(items.length)),
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return DismissibleWidget(
                        key: UniqueKey(),
                        item: item,
                        leftSwipeIcon: Icons.shopping_cart,
                        leftSwipeText: 'To Groceries',
                        leftSwipeColor: Theme.of(context).primaryColor,
                        rightSwipeIcon: Icons.delete_forever,
                        rightSwipeText: 'Delete',
                        rightSwipeColor: Colors.red,
                        child: _PantryTile(
                          item: item,
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            context
                                .read<PantryOverviewBloc>()
                                .add(PantryOverviewItemDeleted(item));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} deleted'),
                              ),
                            );
                          } else if (direction == DismissDirection.endToStart) {
                            context.read<PantryOverviewBloc>().add(
                                PantryOverviewMoveBetweenLists(
                                    item: item, inGroceryList: true));
                            return false;
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  // const Divider(),
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
    return GestureDetector(
      child: ListTile(
        dense: true,
        leading: item.inGroceryList
            ? Icon(Icons.shopping_cart,
                color: Theme.of(context).primaryColorLight)
            : null,
        title: Text(item.name),
        subtitle: Text('Added ${item.daysAgo()}'),
        trailing: SizedBox(
          width: 150,
          height: 150,
          child: DropdownButton<FoodAmount>(
            value: item.amount,
            items: FoodAmount.amounts
                .map<DropdownMenuItem<FoodAmount>>((Amount value) {
              FoodAmount amount = FoodAmount(value);
              return DropdownMenuItem<FoodAmount>(
                value: amount,
                child: Text(amount.displayName),
              );
            }).toList(),
            onChanged: (FoodAmount? newAmount) {
              if (newAmount != null) {
                context.read<PantryOverviewBloc>().add(
                    PantryOverviewAmountChanged(
                        item: item, amount: newAmount.toString()));
              }
            },
          ),
        ),
        onLongPress: () => Navigator.of(context)
            .push(EditPantryItemPage.route(initialItem: item)),
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
