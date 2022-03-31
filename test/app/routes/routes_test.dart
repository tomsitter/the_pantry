import 'package:flutter/material.dart';
import 'package:the_pantry/app/app.dart';
import 'package:the_pantry/home/home.dart';
import 'package:the_pantry/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('onGenerateAppViewPages', () {
    test('returns [HomeScreen] when authenticated', () {
      expect(
        onGenerateAppViewPages(AppStatus.authenticated, []),
        [isA<MaterialPage>().having((p) => p.child, 'child', isA<HomeScreen>())],
      );
    });

    test('returns [LoginScreen] when unauthenticated', () {
      expect(
        onGenerateAppViewPages(AppStatus.unauthenticated, []),
        [isA<MaterialPage>().having((p) => p.child, 'child', isA<LoginScreen>())],
      );
    });
  });
}