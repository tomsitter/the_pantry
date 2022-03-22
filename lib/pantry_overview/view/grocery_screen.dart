import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/constants.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';
import 'package:the_pantry/home/home.dart';

class GroceryScreen extends StatelessWidget {
  static const String id = 'grocery_screen';
  final Color color;

  const GroceryScreen({required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeCubit>().state;
    bool showGroceries = homeState.tab == HomeTab.grocery;

    return BlocProvider(
      create: (context) => PantryOverviewBloc(
        pantryRepository: context.read<PantryRepository>(),
        authRepository: context.read<AuthenticationRepository>(),
      )
        ..add(const PantryOverviewSubscriptionRequested())
        ..add(PantryOverviewFilterChanged(
            filter: showGroceries
                ? const PantryFilter.groceriesOnly()
                : const PantryFilter.pantryOnly())),
      child: GroceryOverviewView(showGroceries: showGroceries),
    );
  }
}

class GroceryOverviewView extends StatelessWidget {
  final bool showGroceries;

  const GroceryOverviewView({required this.showGroceries, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

            int numItems =
                showGroceries ? state.filteredItems.length : state.items.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '$numItems nm /Items',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 32.0),
                      const PantrySearchField(),
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
                      child: showGroceries
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
          backgroundColor: MaterialStateProperty.all<Color>(
              showGroceries ? AppTheme.blue : AppTheme.redBrown),
        ),
        onPressed: () {
          Navigator.of(context).push(
            EditPantryItemPage.route(),
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
    return Expanded(
      child: TextField(
        autofocus: false,
        onChanged: (searchText) {
          context.read<PantryOverviewBloc>().add(PantryOverviewFilterChanged(
              // TODO make this rebuild on change
              filter: PantryFilter.groceriesOnly(searchText)));
        },
        // _runFilter(pantryList.items, value),
        // style: const TextStyle(
        //   color: Colors.black,
        // ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          labelText: 'Search',
          labelStyle: const TextStyle(
            color: Colors.white,
          ),
          suffixIcon: const Icon(Icons.search, color: Colors.white),
        ),
      ),
    );
  }
}
//         ],
//         child: SafeArea(
//         child: BlocConsumer<PantryCubit, PantryState>(
//           listener: (context, state) {
//             if (state.status == PantryStatus.initial) {
//               context.read<PantryCubit>().fetchPantryList();
//             }
//           },
//           builder: (context, state) {
//             if (state.status == PantryStatus.initial) {
//               return const Center(
//                   child: CircularProgressIndicator(color: AppTheme.warmRed));
//             }
//
//             final pantryList = state.pantryList;
//             _foundItems = pantryList.groceries;
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 32.0, vertical: 8.0),
//                   child: Row(
//                     children: [
//                       Text(
//                         '${pantryList.countGroceries} Items',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(width: 32.0),
//                       Expanded(
//                         child: TextField(
//                           autofocus: false,
//                           controller: searchController,
//                           onChanged: (value) =>
//                               _runFilter(pantryList.items, value),
//                           style: const TextStyle(
//                             color: Colors.white,
//                           ),
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white.withOpacity(0.3),
//                             labelText: 'Search',
//                             labelStyle: const TextStyle(
//                               color: Colors.white,
//                             ),
//                             suffixIcon:
//                                 const Icon(Icons.search, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(12.0),
//                         topRight: Radius.circular(12.0),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                           left: 8.0, top: 8.0, right: 8.0, bottom: 88.0),
//                       child: DismissibleGroceryList(displayItems: _foundItems),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//       floatingActionButton: ElevatedButton(
//         style: ButtonStyle(
//           backgroundColor: MaterialStateProperty.all<Color>(widget.color),
//         ),
//         onPressed: () => showModalBottomSheet(
//           isScrollControlled: true,
//           context: context,
//           builder: (context) =>
//               AddItemModal(inGroceryList: true, color: widget.color),
//         ),
//         child: Wrap(
//           crossAxisAlignment: WrapCrossAlignment.center,
//           children: const [
//             Icon(Icons.add),
//             Text('Add item'),
//           ],
//         ),
//       ),
//     );
//   }
// }
