import 'package:flutter/widgets.dart';
import 'package:the_pantry/app/app.dart';
import 'package:the_pantry/login/login.dart';
import 'package:the_pantry/home/home.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomeScreen.page()];
    case AppStatus.unauthenticated:
      return [LoginScreen.page()];
  }
}
