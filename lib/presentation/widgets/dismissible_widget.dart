import 'package:flutter/material.dart';

const DismissDirection left = DismissDirection.endToStart;
const DismissDirection right = DismissDirection.startToEnd;

/// A [DismissibleWidget] supports swipe-to-dismiss functionality,
/// with different callbacks for left and right swipes.
/// One direction must delete the item, the other
class DismissibleWidget<T> extends StatelessWidget {
  final T item;
  final Widget child;
  final DismissDirectionCallback? onDismissed;
  final IconData leftSwipeIcon;
  final String leftSwipeText;
  final Color leftSwipeColor;
  final IconData rightSwipeIcon;
  final String rightSwipeText;
  final Color rightSwipeColor;
  // On pantry screen do not want to dismiss items added to groceries
  final ConfirmDismissCallback? confirmDismiss;

  const DismissibleWidget({
    required this.item,
    required this.child,
    required this.leftSwipeIcon,
    required this.leftSwipeText,
    required this.leftSwipeColor,
    required this.rightSwipeIcon,
    required this.rightSwipeText,
    required this.rightSwipeColor,
    this.onDismissed,
    this.confirmDismiss,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ObjectKey(item),
        // background shown when widget swiped right or down
        background: buildSwipeAction(
            right, rightSwipeColor, rightSwipeIcon, rightSwipeText),
        // secondaryBackground shown when widget swiped left or up
        secondaryBackground: buildSwipeAction(
            left, leftSwipeColor, leftSwipeIcon, leftSwipeText),
        child: child,
        onDismissed: onDismissed,
        confirmDismiss: confirmDismiss,
      );
}

Widget buildSwipeAction(
        DismissDirection direction, Color color, IconData icon, String text) =>
    Container(
      alignment:
          direction == right ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: dismissActionIcon(icon, text,
          direction == left ? MainAxisAlignment.end : MainAxisAlignment.start),
    );

Widget dismissActionIcon(
        IconData icon, String text, MainAxisAlignment alignment) =>
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: alignment,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
