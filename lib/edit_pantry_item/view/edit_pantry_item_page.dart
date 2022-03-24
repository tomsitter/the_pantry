import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/edit_pantry_item/bloc/edit_pantry_item_bloc.dart';

class EditPantryItemPage extends StatelessWidget {
  final PantryItem? initialItem;
  final bool isGroceryScreen;

  const EditPantryItemPage(
      {this.initialItem, required this.isGroceryScreen, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditPantryItemBloc(
          pantryRepository: context.read<PantryRepository>(),
          authRepository: context.read<AuthenticationRepository>(),
          initialItem: initialItem,
          isGroceryScreen: isGroceryScreen),
      child: BlocListener<EditPantryItemBloc, EditPantryItemState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == EditPantryItemStatus.success,
        listener: (context, state) => Navigator.of(context).pop(),
        child: const EditPantryItemView(),
      ),
    );
  }
}

class EditPantryItemView extends StatelessWidget {
  const EditPantryItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status =
        context.select((EditPantryItemBloc bloc) => bloc.state.status);
    final isFormValid =
        context.select((EditPantryItemBloc bloc) => bloc.state.isFormValid);
    final isNewItem =
        context.select((EditPantryItemBloc bloc) => bloc.state.isNewItem);
    final bool isGroceryScreen =
        context.select((EditPantryItemBloc bloc) => bloc.state.isGroceryScreen);
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: Text(isNewItem ? "Add an item" : "Edit item")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: status.isLoadingOrSuccess
            ? fabBackgroundColor.withOpacity(0.5)
            : fabBackgroundColor,
        onPressed: status.isLoadingOrSuccess || !isFormValid
            ? null
            : () => context
                .read<EditPantryItemBloc>()
                .add(const EditPantryItemSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const _NameField(),
                  // only show amount remaining from grocery screen, not pantry
                  isGroceryScreen ? Container() : const _AmountField(),
                  const _CategoryField(),
                  const _InGroceryField(),
                ],
              )),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: const Key('editPantryItemView_name_textFormField'),
            initialValue: state.name.value,
            decoration: InputDecoration(
                enabled: !state.status.isLoadingOrSuccess,
                labelText: "name",
                errorText: state.name.invalid ? 'Name too short' : null),
            onChanged: (value) {
              context.read<EditPantryItemBloc>().add(EditPantryItemName(value));
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    // final hintText = state.initialItem?.category ?? FoodCategory.uncategorized;

    return Row(
      children: [
        const Text("Category:"),
        Expanded(
          child: DropdownButton(
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
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditPantryItemBloc>().state;
    // final hintText = state.initialItem?.category ?? FoodCategory.uncategorized;

    return Row(
      children: [
        const Text("Amount remaining:"),
        Expanded(
          child: DropdownButtonFormField(
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
        ),
      ],
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
      title: const Text("Show in grocery list"),
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
