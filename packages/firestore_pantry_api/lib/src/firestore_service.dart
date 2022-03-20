import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantry_api/pantry_api.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream<PantryList> streamUserData(String userId) {
  //   return _firestore
  //       .collection('user_data')
  //       .doc(userId)
  //       .snapshots()
  //       .map((snap) => PantryList.fromFirestore(snap));
  // }
  //
  // Future<PantryList> getUserDataSnapshot(String userId) async {
  //   return _firestore
  //       .collection('user_data')
  //       .doc(userId)
  //       .get()
  //       .then((data) => PantryList.fromFirestore(data))
  //       .catchError(
  //     (e) {
  //       if (e.code == "NOT_FOUND") {
  //         var newPantryList = PantryList(items: <PantryItem>[]);
  //         updateUser(userId, newPantryList);
  //         return newPantryList;
  //       }
  //     },
  //   );
  // }

  Future<void> updateUser(String userId, PantryList pantryList) {
    return _firestore
        .collection('user_data')
        .doc(userId)
        .set(pantryList.toJson());
  }

  Future<Map<String, dynamic>?> fetchPantryItems(String userId) async {
    return await _firestore
        .collection('user_data')
        .doc(userId)
        .get()
        .then((docSnapshot) => docSnapshot.data())
        .catchError((e) {
      print('An error occurred in fetch');
      return <String, dynamic>{};
    });
  }

  Future<Map<String, dynamic>?> createNewPantry(String userId) async {
    return await _firestore
        .collection('user_data')
        .doc(userId)
        .set({"pantry": {}})
        .then((_) => fetchPantryItems(userId))
        .catchError((error) {
          print("Failed to create a new pantry for user");
          return <String, dynamic>{};
        });
  }

  Future<bool> updateItem(
      String name, Map<String, dynamic> item, String userId) async {
    /// Overwrites an item with the same name property.
    try {
      return await _firestore
          .collection('user_data')
          .doc(userId)
          .update({'pantry.$name': item[name]}).then((value) => true);
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteItem(String name, String userId) async {
    try {
      return await _firestore
          .collection('user_data')
          .doc(userId)
          .update({'pantry.$name': FieldValue.delete()}).then((value) => true);
    } catch (_) {
      print('An error occurred');
      return;
    }
  }
}
