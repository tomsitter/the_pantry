import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_pantry_api/firestore_pantry_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'firebase_options.dart';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:food_dictionary_repository/food_dictionary_repository.dart';
import 'package:the_pantry/app/app.dart';

const bool useFirestoreEmulator = false;

Future main() async {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (useFirestoreEmulator) {
        FirebaseFirestore.instance.settings = const Settings(
            host: 'localhost:8080',
            sslEnabled: false,
            persistenceEnabled: false);
      }

      // FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      final authRepository = AuthenticationRepository();
      await authRepository.user.first;
      final data = await rootBundle.loadString('assets/data/foods.json');
      final foodRepository = FoodRepository.fromJson(json.decode(data));
      final pantryApi = FirestorePantryApi(
          instance: FirebaseFirestore.instance,
          docId: authRepository.currentUser.id);
      final pantryRepository = PantryRepository(pantryApi: pantryApi);

      runApp(
        App(
          authenticationRepository: authRepository,
          foodRepository: foodRepository,
          pantryRepository: pantryRepository,
        ),
      );
    },
    // blocObserver: AppBlocObserver(),
  );
}
