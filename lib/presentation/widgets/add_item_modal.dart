import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bloc/pantry_cubit.dart';

/// [AddItemModal] is a screen that pops up from the bottom of the screen
/// to allow users to add a new item to either the pantry or the grocery lists
///
/// It requires a reference to the list that it will add to (either [GroceryList]
/// or [PantryList], and a color to match that of the parent screen
class AddItemModal extends StatelessWidget {
  final _textController = TextEditingController();
  final bool inGroceryList;
  final Color color;

  AddItemModal({
    Key? key,
    required this.inGroceryList,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PantryCubit, PantryState>(
      listener: (context, state) {
        if (state.status == PantryStatus.loaded) {
          Navigator.pop(context);
          return;
        }
      },
      child: Material(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Add item',
                  style: TextStyle(color: color, fontSize: 24.0),
                ),
              ),
              TextField(
                controller: _textController,
                textAlign: TextAlign.center,
                autofocus: true,
              ),
              BlocBuilder<PantryCubit, PantryState>(
                builder: (context, state) {
                  if (state.status == PantryStatus.loading) {
                    return Center(
                        child: CircularProgressIndicator(color: color));
                  }
                  if (state.status == PantryStatus.error) {
                    Fluttertoast.showToast(msg: state.error);
                  }
                  return TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 64.0)),
                      backgroundColor: MaterialStateProperty.all<Color>(color),
                    ),
                    onPressed: () {
                      final itemName = _textController.text;
                      BlocProvider.of<PantryCubit>(context)
                          .addItem(itemName, inGroceryList);
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
