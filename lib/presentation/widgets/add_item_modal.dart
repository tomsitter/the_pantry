import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:the_pantry/bloc/add_item_cubit.dart';

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
    return BlocListener<AddItemCubit, AddItemState>(
      listener: (context, state) {
        if (state is AddItemComplete) {
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
              BlocBuilder<AddItemCubit, AddItemState>(
                builder: (context, state) {
                  if (state is AddItemInProgress) {
                    return Center(
                        child: CircularProgressIndicator(color: color));
                  }

                  if (state is AddItemError) {
                    Fluttertoast.showToast(msg: state.error);
                  }
                  // if (state is AddItemError) {
                  //   showFlash(
                  //       context: context,
                  //       builder: (context, controller) {
                  //         return Flash(
                  //           controller: controller,
                  //           child: FlashBar(
                  //             content: Text(state.error),
                  //           ),
                  //         );
                  //       });
                  // }

                  return TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 64.0)),
                      backgroundColor: MaterialStateProperty.all<Color>(color),
                    ),
                    onPressed: () {
                      final itemName = _textController.text;
                      BlocProvider.of<AddItemCubit>(context)
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
