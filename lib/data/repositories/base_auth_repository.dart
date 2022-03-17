import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthRepository {
  Stream<User?> get user;
  Future<String> signUp({required String email, required String password});
}
