import 'package:flutter/material.dart';
import 'colors.dart';

class CustomTheme {
  static ThemeData get light {
    return ThemeData(
        // textTheme: GoogleFonts.openSansTextTheme(),
        primaryColorLight: CustomColors.blue,
        primaryColor: CustomColors.blue,
        appBarTheme: const AppBarTheme(
          color: CustomColors.blue,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: CustomColors.almostWhite,
          indicator: const ShapeDecoration(
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: CustomColors.paleYellow,
                width: 4.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          unselectedLabelColor: Colors.grey[1000],
        ),
        textTheme: const TextTheme(
            // headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold)
            ),
        secondaryHeaderColor: CustomColors.redBrown,
        scaffoldBackgroundColor: CustomColors.almostWhite,
        inputDecorationTheme: InputDecorationTheme(
          focusColor: CustomColors.almostWhite,
          fillColor: CustomColors.almostWhite,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: CustomColors.darkBlue,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: CustomColors.palePink,
              width: 10,
            ),
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: CustomColors.teal,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: CustomColors.blue,
          disabledElevation: 0.0,
        ));
  }

  static ThemeData get dark {
    return ThemeData.dark();
  }

  static ThemeData get secondaryLight {
    return ThemeData.light().copyWith(
      primaryColorLight: CustomColors.redBrown,
      tabBarTheme: const TabBarTheme(
        labelColor: CustomColors.almostWhite,
        indicator: ShapeDecoration(
          shape: UnderlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.paleYellow,
              width: 4.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        // labelColor: CustomColors.almostWhite,
        unselectedLabelColor: CustomColors.paleBlue,
      ),
    );
  }
}
