import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_pantry/data/models/pantry_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<PantryList> streamUserData(User user) {
    return _firestore
        .collection('user_data')
        .doc(user.uid)
        .snapshots()
        .map((snap) => PantryList.fromFirestore(snap));
  }

  Future<PantryList> getUserDataSnapshot(User user) async {
    return _firestore
        .collection('user_data')
        .doc(user.uid)
        .get()
        .then((data) => PantryList.fromFirestore(data))
        .catchError(
      (e) {
        if (e.code == "NOT_FOUND") {
          var newPantryList = PantryList(items: <PantryItem>[]);
          updateUser(user, newPantryList);
          return newPantryList;
        }
      },
    );
  }

  Future<void> updateUser(User user, PantryList pantryList) {
    return _firestore
        .collection('user_data')
        .doc(user.uid)
        .set(pantryList.toJson());
  }

  Future<Map<String, dynamic>?> fetchPantryItems(User user) async {
    return await _firestore
        .collection('user_data')
        .doc(user.uid)
        .get()
        .then((docSnapshot) => docSnapshot.data())
        .catchError((e) {
      print('An error occurred in fetch');
      return <String, dynamic>{};
    });
  }

  Future<Map<String, dynamic>?> createNewPantry(User user) async {
    return await _firestore
        .collection('user_data')
        .doc(user.uid)
        .set({"pantry": {}})
        .then((_) => fetchPantryItems(user))
        .catchError((error) {
          print("Failed to create a new pantry for user");
          return <String, dynamic>{};
        });
  }

  Future<bool> updateItem(
      String name, Map<String, dynamic> item, User user) async {
    /// Overwrites an item with the same name property.
    try {
      return await _firestore
          .collection('user_data')
          .doc(user.uid)
          .update({'pantry.$name': item[name]}).then((value) => true);
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(String name, User user) async {
    try {
      return await _firestore
          .collection('user_data')
          .doc(user.uid)
          .update({'pantry.$name': FieldValue.delete()}).then((value) => true);
    } catch (e) {
      return false;
    }
  }
}
