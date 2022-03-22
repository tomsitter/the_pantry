import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:firestore_pantry_api/firestore_pantry_api.dart';
import 'package:the_pantry/app/app.dart';

Future main() async {
  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      final authRepository = AuthenticationRepository();
      final pantryApi =
          FirestorePantryApi(instance: FirebaseFirestore.instance);
      await authRepository.user.first;
      final pantryRepository = PantryRepository(pantryApi: pantryApi);
      runApp(
        App(
          authenticationRepository: authRepository,
          pantryRepository: pantryRepository,
        ),
      );
    },
    blocObserver: AppBlocObserver(),
  );
}
