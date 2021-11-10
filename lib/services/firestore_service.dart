import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_pantry/models/user_data.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<UserData> streamUserData(User user) {
    return firestore
        .collection('user_data')
        .doc(user.uid)
        .snapshots()
        .map((snap) => UserData.fromFirestore(snap));
  }

  Future<void> updateUserData(User user, UserData userData) {
    return firestore
        .collection('user_data')
        .doc(user.uid)
        .set(userData.toJson());
  }
}
