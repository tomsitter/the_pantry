import 'package:flutter/material.dart';

import 'package:the_pantry/constants.dart';

class DismissibleWidget<T> extends StatelessWidget {
  static const DismissDirection left = DismissDirection.endToStart;
  static const DismissDirection right = DismissDirection.startToEnd;
  final T item;
  final Widget child;
  final DismissDirectionCallback? onDismissed;
  final IconData altDismissIcon;
  final String altDismissText;
  final DismissDirection deleteDirection;
  // On pantry screen do not want to dismiss items added to groceries
  final ConfirmDismissCallback? confirmDismiss;

  const DismissibleWidget({
    required this.item,
    required this.child,
    required this.altDismissIcon,
    required this.altDismissText,
    this.onDismissed,
    this.deleteDirection = left,
    this.confirmDismiss,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ObjectKey(item),
        // background shown when widget swiped right or down
        background: deleteDirection == left
            ? buildAlternateAction()
            : buildDeleteAction(),
        // secondaryBackground shown when widget swiped left or up
        secondaryBackground: deleteDirection == left
            ? buildDeleteAction()
            : buildAlternateAction(),
        child: child,
        onDismissed: onDismissed,
        confirmDismiss: confirmDismiss,
      );

  Widget buildDeleteAction() => Container(
        alignment: deleteDirection == left
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete_forever, color: Colors.white, size: 24),
      );

  Widget buildAlternateAction() => Container(
        alignment: deleteDirection == left
            ? Alignment.centerLeft
            : Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: AppTheme.paleTeal,
        child: dismissActionIcon(altDismissIcon, altDismissText),
      );

  Widget dismissActionIcon(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: deleteDirection == left
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      );
}
