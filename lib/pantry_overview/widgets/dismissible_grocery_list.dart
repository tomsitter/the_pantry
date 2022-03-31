import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';
import 'package:the_pantry/search/search.dart';
import 'package:the_pantry/home/home.dart';

class DismissibleGroceryList extends StatelessWidget {
  final List<PantryItem> displayItems;

  const DismissibleGroceryList({required this.displayItems, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PantryOverviewBloc, PantryOverviewState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return Column(
              children: [
                DismissibleWidget(
                  key: Key('dismissibleGroceryList_dismissibleWidget_$index'),
                  item: item,
                  leftSwipeIcon: Icons.delete_forever,
                  leftSwipeText: 'Delete',
                  leftSwipeColor: Colors.red,
                  rightSwipeIcon: Icons.home,
                  rightSwipeText: 'To Pantry',
                  rightSwipeColor: Theme.of(context).primaryColorLight,
                  child: _GroceryTile(
                    item: item,
                    checkboxCallback: (bool? checkboxState) {
                      context.read<PantryOverviewBloc>().add(
                          PantryOverviewGroceryToggled(
                              item: item, isChecked: checkboxState!));
                    },
                    onLongPressCallback: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => RepositoryProvider.value(
                            value: context.read<PantryRepository>(),
                            child: BlocProvider.value(
                              value: context.read<SearchCubit>(),
                              child: EditPantryItemPage(
                                initialItem: item,
                                isGroceryScreen: context.select((HomeCubit cubit) => cubit.isGroceryScreen),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  confirmDismiss: (direction) async {
                    // delete direction
                    if (direction == DismissDirection.endToStart) {
                      context
                          .read<PantryOverviewBloc>()
                          .add(PantryOverviewItemDeleted(item));
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.name} deleted')));
                      return true;
                      // to pantry direction
                    } else if (direction == DismissDirection.startToEnd) {
                      context.read<PantryOverviewBloc>().add(
                          PantryOverviewMoveBetweenLists(
                              item: item, inGroceryList: false));
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
  final VoidCallback onLongPressCallback;

  const _GroceryTile(
      {Key? key,
      required this.item,
      required this.checkboxCallback,
      required this.onLongPressCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CheckboxListTile(
        dense: true,
        title: Text(
          item.name,
          style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : null),
        ),
        value: item.isChecked,
        onChanged: checkboxCallback,
      ),
      onLongPress: onLongPressCallback,
    );
  }
}
