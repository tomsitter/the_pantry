import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PantryFilter filter =
        context.select((PantryOverviewBloc bloc) => bloc.state.filter);
    final isFormValid = context.select((EditPantryItemBloc bloc) => bloc.state.isFormValid);
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: false,
                  controller: _textController,
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
                      onPressed: isFormValid ? () => _quickAdd(filter) : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

  void _quickAdd(PantryFilter filter) {
    context
        .read<EditPantryItemBloc>()
        .add(const EditPantryItemSubmitted());

    context.read<PantryOverviewBloc>().add(
      PantryOverviewFilterChanged(
        filter: filter.isGroceryFilter
            ? const PantryFilter.groceriesOnly()
            : const PantryFilter.pantryOnly(),
      ),
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added ${_textController.text}'),
        ),
      );
    _textController.value = TextEditingValue.empty;
    FocusScope.of(context).unfocus();
  }

}

