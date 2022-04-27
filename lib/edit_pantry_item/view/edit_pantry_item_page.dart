import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/edit_pantry_item/bloc/edit_pantry_item_bloc.dart';
import 'package:the_pantry/search/search.dart';

class EditPantryItemPage extends StatelessWidget {
  final PantryItem? initialItem;
  final bool isGroceryScreen;
  final bool? isNewItem;

  const EditPantryItemPage(
      {this.initialItem,
      this.isNewItem,
      required this.isGroceryScreen,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EditPantryItemBloc(
              pantryRepository: context.read<PantryRepository>(),
              authRepository: context.read<AuthenticationRepository>(),
              initialItem: initialItem,
              isGroceryScreen: isGroceryScreen),
        ),
        BlocProvider<SearchBloc>(
          create: (context) =>
              SearchBloc(foodRepository: context.read<FoodRepository>()),
        ),
      ],
      child: BlocListener<EditPantryItemBloc, EditPantryItemState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == EditPantryItemStatus.success,
        listener: (context, state) => Navigator.of(context).pop(),
        child: EditPantryItemView(isNewItem: isNewItem),
      ),
    );
  }
}

class EditPantryItemView extends StatelessWidget {
  final bool? isNewItem;

  const EditPantryItemView({this.isNewItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.read<EditPantryItemBloc>().state;
    final isGroceryScreen = state.isGroceryScreen;

    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(isNewItem ?? false ? 'Add an item' : 'Edit item')),
        floatingActionButton:
            BlocBuilder<EditPantryItemBloc, EditPantryItemState>(
          builder: (context, state) {
            return FloatingActionButton(
              backgroundColor: state.canSubmit
                  ? fabBackgroundColor
                  : fabBackgroundColor.withOpacity(0.5),
              onPressed: state.canSubmit
                  ? () => context
                      .read<EditPantryItemBloc>()
                      .add(const EditPantryItemSubmitted())
                  : null,
              child: state.status.isLoadingOrSuccess
                  ? const CupertinoActivityIndicator()
                  : const Icon(Icons.check_rounded),
            );
          },
        ),
        body: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // const _NameField(),
                    const _AutoCompleteNameField(),
                    // only show amount remaining from grocery screen, not pantry
                    isGroceryScreen ? Container() : const _AmountField(),
                    const _CategoryField(),
                    const _InGroceryField(),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class _AutoCompleteNameField extends StatelessWidget {
  const _AutoCompleteNameField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    final searchState = context.watch<SearchBloc>().state;

    return ListTile(
      autofocus: true,
      title: Autocomplete<PantryItem>(
        displayStringForOption: (PantryItem item) => item.name,
        optionsBuilder: (TextEditingValue textEditingValue) {
          String searchText = textEditingValue.text;
          context
              .read<EditPantryItemBloc>()
              .add(EditPantryItemName(searchText));
          context.read<SearchBloc>().add(SearchTextChanged(searchText));
          print(searchText);
          return searchState.matchedItems.toList();
        },
        key: const Key('editPantryItemView_name_textFormField'),
        initialValue: TextEditingValue(text: state.name.value),
        optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Theme.of(context).primaryColorLight,
              elevation: 4.0,
              // size works, when placed here below the Material widget
              child: Container(
                  // I have the text field wrapped in a container with
                  // EdgeInsets.all(20) so subtract 40 from the width for the width
                  // of the text box. You could also just use a padding widget
                  // with EdgeInsets.only(right: 20)
                  width: MediaQuery.of(context).size.width - 40,
                  child: ListView.builder(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        tileColor: Colors.white,
                        dense: true,
                        title: Text(options.elementAt(index).name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => print('selected ${options.elementAt(index).name}')
                        ),
                      );
                    },
                  ),),
            ),),
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            decoration: const InputDecoration(
              hintText: 'Name',
            ),
            autofocus: true,
            focusNode: focusNode,
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
          );
        },
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    // final hintText = state.initialItem?.category ?? FoodCategory.uncategorized;

    return ListTile(
      dense: true,
      title: const Text('Category: '),
      subtitle: DropdownButton(
          key: const Key('editPantryItemView_category_dropdownTextField'),
          value: state.category,
          items: FoodCategory.categories
              .map<DropdownMenuItem<FoodCategory>>((FoodType value) {
            FoodCategory category = FoodCategory(value);
            return DropdownMenuItem<FoodCategory>(
              value: category,
              child: Text(category.displayName),
            );
          }).toList(),
          onChanged: (FoodCategory? value) {
            context
                .read<EditPantryItemBloc>()
                .add(EditPantryItemCategory(value!));
          }),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    // final hintText = state.initialItem?.category ?? FoodCategory.uncategorized;

    return ListTile(
      dense: true,
      title: const Text('Amount remaining:'),
      subtitle: DropdownButtonFormField(
          value: state.amount,
          key: const Key('editPantryItemView_amount_dropdownTextField'),
          items: FoodAmount.amounts
              .map<DropdownMenuItem<FoodAmount>>((Amount value) {
            FoodAmount amount = FoodAmount(value);
            return DropdownMenuItem<FoodAmount>(
              value: amount,
              child: Text(amount.displayName),
            );
          }).toList(),
          onChanged: (FoodAmount? value) {
            context
                .read<EditPantryItemBloc>()
                .add(EditPantryItemAmount(value!));
          }),
    );
  }
}

class _InGroceryField extends StatelessWidget {
  const _InGroceryField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    // final hintText = state.initialItem?.category ?? FoodCategory.uncategorized;

    return CheckboxListTile(
      title: const Text('Show in grocery list'),
      value: state.inGroceryList,
      key: const Key('editPantryItemView_inGroceries_checkboxListTile'),
      onChanged: (bool? value) {
        if (value != null) {
          context
              .read<EditPantryItemBloc>()
              .add(EditPantryItemInGroceries(value));
        }
      },
    );
  }
}
