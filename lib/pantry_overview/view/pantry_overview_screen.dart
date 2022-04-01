import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/home/home.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:the_pantry/search/search.dart';

class PantryOverviewScreen extends StatelessWidget {
  static const String id = 'grocery_screen';

  const PantryOverviewScreen({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GroceryOverviewView();
  }
}

class GroceryOverviewView extends StatelessWidget {
  const GroceryOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isGroceryScreen =
        context.select((HomeCubit cubit) => cubit.isGroceryScreen);

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<PantryOverviewBloc, PantryOverviewState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == PantryOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ??
                          'An unspecified error occurred'),
                    ),
                  );
              }
              if (state.status == PantryOverviewStatus.success) {}
            },
          ),
          BlocListener<PantryOverviewBloc, PantryOverviewState>(
              listenWhen: (previous, current) =>
                  previous.lastDeletedItem != current.lastDeletedItem &&
                  current.lastDeletedItem != null,
              listener: (context, state) {
                final deletedItem = state.lastDeletedItem!;
                final messenger = ScaffoldMessenger.of(context);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("Deleted ${deletedItem.name}, tap to undo"),
                      action: SnackBarAction(
                          label: "Undo",
                          onPressed: () {
                            messenger.hideCurrentSnackBar();
                            context.read<PantryOverviewBloc>().add(
                                const PantryOverviewUndoDeletionRequested());
                          }),
                    ),
                  );
              }),
        ],
        child: BlocBuilder<PantryOverviewBloc, PantryOverviewState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              if (state.status == PantryOverviewStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status != PantryOverviewStatus.success) {
                return const SizedBox();
              } else {
                return const Center(child: Text('No items'));
              }
            }

            // int numItems =
            //     showGroceries ? state.filteredItems.length : state.items.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isGroceryScreen ? const PantrySearchField() : Container(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8.0, right: 8.0, bottom: 88.0),
                      child: isGroceryScreen
                          ? DismissibleGroceryList(
                              displayItems: state.filteredItems.toList())
                          : DismissiblePantryList(
                              displayItems: state.filteredItems.toList()),
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
          backgroundColor: MaterialStateProperty.all<Color>(isGroceryScreen
              ? Theme.of(context).primaryColor
              : Theme.of(context).secondaryHeaderColor),
        ),
        onPressed: () {
          final state = context.read<PantryOverviewBloc>().state;
          // final bool isGroceryScreen = context.select((HomeCubit cubit) => cubit.isGroceryScreen);
          final int numFilteredItems = state.filteredItems.length;
          final String newItemName;
          if (numFilteredItems == 0) {
            String searchText = state.filter.searchText;
            newItemName = searchText;
          } else {
            newItemName = '';
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => RepositoryProvider.value(
                value: context.read<PantryRepository>(),
                child: EditPantryItemPage(
                  isGroceryScreen: isGroceryScreen,
                  initialItem: PantryItem(
                      name: newItemName, inGroceryList: isGroceryScreen),
                ),
              ),
            ),
          );
        },
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

class PantrySearchField extends StatelessWidget {
  const PantrySearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isGroceryScreen =
        context.select((HomeCubit cubit) => cubit.isGroceryScreen);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: Row(
        children: [
          // Text(
          //   '$numItems Items',
          // ),
          Expanded(
            child: TextField(
              autofocus: false,
              onChanged: (searchText) {
                context.read<PantryOverviewBloc>().add(
                    PantryOverviewFilterChanged(
                        filter: isGroceryScreen
                            ? PantryFilter.groceriesOnly(searchText)
                            : PantryFilter.pantryOnly(searchText)));
              },
              // _runFilter(pantryList.items, value),
              // style: const TextStyle(
              //   color: Colors.black,
              // ),
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}