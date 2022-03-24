import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  StreamController<Map<String, dynamic>?> pantryController =
      StreamController<Map<String, dynamic>?>();

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

  Stream<DocumentSnapshot> listenOnUserDocument(String userId) async* {
    final docReference = await _firestore.collection('user_data').doc(userId);
    await for (final snapshot in docReference.snapshots()) {
      yield snapshot;
    }
    // .listen((snapshot) {
    //   final data = snapshot.data();
    //   if (data != null) pantryController.add(data);
    // });
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
      String id, Map<String, dynamic> item, String userId) async {
    /// Overwrites an item with the same name property or creates a new item.
    try {
      return await _firestore
          .collection('user_data')
          .doc(userId)
          .update({'pantry.$id': item[id]}).then((value) => true);
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteItem(String id, String userId) async {
    try {
      return await _firestore
          .collection('user_data')
          .doc(userId)
          .update({'pantry.$id': FieldValue.delete()}).then((value) => true);
    } catch (_) {
      print('An error occurred');
      return;
    }
  }
}
