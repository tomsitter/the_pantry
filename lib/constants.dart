import 'package:flutter/material.dart';

class AppTheme {
  static const Color warmRed = Color(0xffC01B21);
  static const Color paleTeal = Color(0xff93C6B3);
  static const Color teal = Color(0xFF6BB5B6);
  static const Color paleYellow = Color(0xFFF5DF67);
  static const Color almostWhite = Color(0xffeaf4fb);
  static const Color palePink = Color(0xFFFFCBC2);
  static const Color paleBlue = Color(0xFFbfdef3);
  static const Color blue = Color(0xFF72C1E8);
  static const Color darkBlue = Color(0xFF40a4dd);
  static const Color redBrown = Color(0xFFB35034);

  static const textFieldDecoration = InputDecoration(
    hintText: '',
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(32.0),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: darkBlue, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: darkBlue, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
    filled: true,
    fillColor: Colors.white,
  );
}
