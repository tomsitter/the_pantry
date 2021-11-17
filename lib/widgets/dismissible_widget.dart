import 'package:flutter/material.dart';

import '../constants.dart';

class DismissibleWidget<T> extends StatelessWidget {
  static const DismissDirection left = DismissDirection.endToStart;
  static const DismissDirection right = DismissDirection.startToEnd;
  // static const DismissDirection right = DismissDirection.startToEnd;
  final T item;
  final Widget child;
  final DismissDirectionCallback onDismissed;
  final IconData altListIcon;
  final DismissDirection deleteDirection;

  const DismissibleWidget({
    required this.item,
    required this.child,
    required this.altListIcon,
    required this.onDismissed,
    this.deleteDirection = left,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ObjectKey(item),
        // background shown when widget swiped right or down
        background: deleteDirection == left
            ? buildAlternateAction(deleteDirection)
            : buildDeleteAction(deleteDirection),
        // secondaryBackground shown when widget swiped left or up
        secondaryBackground: deleteDirection == left
            ? buildDeleteAction(deleteDirection)
            : buildAlternateAction(deleteDirection),
        child: child,
        onDismissed: onDismissed,
      );

  Widget buildDeleteAction(DismissDirection deleteDirection) => Container(
        alignment: deleteDirection == left
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete_forever, color: Colors.white, size: 32),
      );

  Widget buildAlternateAction(DismissDirection deleteDirection) => Container(
        alignment: deleteDirection == left
            ? Alignment.centerLeft
            : Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: AppTheme.almostWhite,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Icon(altListIcon, color: Colors.white, size: 32),
            //Text('To Pantry'),
          ],
        ),
      );
}
