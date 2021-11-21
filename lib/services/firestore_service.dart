import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_pantry/models/grocery_model.dart';
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

  Future<UserData> getUserData(User user) async {
    return firestore
        .collection('user_data')
        .doc(user.uid)
        .get()
        .then((data) => UserData.fromFirestore(data))
        .catchError(
      (e) {
        if (e.code == "NOT_FOUND") {
          var newUserData = UserData(<GroceryItem>[]);
          updateUserData(user, newUserData);
          return newUserData;
        }
      },
    );
  }

  Future<void> updateUserData(User user, UserData userData) {
    return firestore
        .collection('user_data')
        .doc(user.uid)
        .set(userData.toJson());
  }
}
