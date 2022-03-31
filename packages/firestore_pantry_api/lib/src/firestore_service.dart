import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // StreamController<Map<String, dynamic>?> pantryController =
  //     StreamController<Map<String, dynamic>?>();

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
    if (userId.isNotEmpty) {
      final docReference = _firestore.collection('user_data').doc(userId);

      /// Create a new empty Pantry if the user does not already have one
      docReference.get()
      .then((docSnapshot) {
        if (!docSnapshot.exists) {
          docReference
              .set({"pantry": {}})
              .then((_) => <String, dynamic>{})
              .catchError((error) {
                print("Failed to create a new pantry for user");
              });
          print("Created new pantry for $userId");
        }
      });

      await for (final snapshot in docReference.snapshots()) {
        print("Yielding snapshot");
        yield snapshot;
      }
    }
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
