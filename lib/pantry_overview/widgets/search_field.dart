import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PantryFilter filter =
        context.select((PantryOverviewBloc bloc) => bloc.state.filter);
    return BlocProvider(
      create: (context) => EditPantryItemBloc(
        pantryRepository: context.read<PantryRepository>(),
        authRepository: context.read<AuthenticationRepository>(),
        isGroceryScreen: filter.isGroceryFilter,
        initialItem: PantryItem(name: ''),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: false,
                onChanged: (searchText) {
                  context.read<PantryOverviewBloc>().add(
                        PantryOverviewFilterChanged(
                          filter: filter.isGroceryFilter
                              ? PantryFilter.groceriesOnly(searchText)
                              : PantryFilter.pantryOnly(searchText),
                        ),
                      );

                  context.read<EditPantryItemBloc>().add(
                        EditPantryItemName(searchText),
                      );
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outlined),
                    onPressed: () {
                      context
                          .read<EditPantryItemBloc>()
                          .add(const EditPantryItemSubmitted());
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
