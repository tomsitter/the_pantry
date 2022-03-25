import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:the_pantry/app/app.dart';

Future main() async {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      final authRepository = AuthenticationRepository();
      await authRepository.user.first;
      final data = await rootBundle.loadString('assets/data/foods.json');
      final foodRepository = FoodRepository.fromJson(json.decode(data));

      runApp(
        App(
          authenticationRepository: authRepository,
          foodRepository: foodRepository,
        ),
      );
    },
    blocObserver: AppBlocObserver(),
  );
}
