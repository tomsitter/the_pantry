import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/search/search.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/edit_pantry_item/edit_pantry_item.dart';

class _AutoCompleteNameField extends StatelessWidget {
  const _AutoCompleteNameField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    final searchState = context.watch<SearchCubit>().state;

    return Row(
      children: [
        Expanded(
          child: Autocomplete<PantryItem>(
            displayStringForOption: (PantryItem item) => item.name,
            optionsBuilder: (TextEditingValue textEditingValue) {
              String searchText = textEditingValue.text;
              context
                  .read<EditPantryItemBloc>()
                  .add(EditPantryItemName(searchText));
              context.read<SearchCubit>().changeSearchText(searchText);
              return searchState.matchedItems;
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                autofocus: true,
                onFieldSubmitted: (String value) {
                  onFieldSubmitted();
                },
                decoration: InputDecoration(
                  enabled: !state.status.isLoadingOrSuccess,
                  labelText: "name",
                  errorText: state.name.invalid ? 'Name too short' : null,
                ),
              );
            },
            key: const Key('editPantryItemView_name_textFormField'),
            initialValue: TextEditingValue(text: state.name.value),
            onSelected: (PantryItem item) {
              if (item.category != state.category) {
                context
                    .read<EditPantryItemBloc>()
                    .add(EditPantryItemCategory(item.category));
              }
            },
          ),
        ),
      ],
    );
  }
}
