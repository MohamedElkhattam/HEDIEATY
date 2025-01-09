import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/model/user_model.dart';

class UserFirestoreCRUD {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addUser(UserModel user) async {
    try {
      await _db.collection('Users').doc(user.firestoreId).set(user.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<UserModel>> retrieveAllUsers() async {
    try {
      QuerySnapshot snapshot = await _db.collection('Users').get();
      List<UserModel> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, doc.id)..firestoreId = doc.id;
        // Create UserModel and assign Firestore ID
      }).toList();

      return users;
    } catch (e) {
      return [];
    }
  }

  static Future<UserModel?> retrieveUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, doc.id)..firestoreId = userId;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> attachFCMToUser(
      String firestoreId, String fcmToken) async {
    try {
      await _db.collection('Users').doc(firestoreId).update({
        'fcmToken': fcmToken,
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<UserModel?> retrieveUserByPhoneNumber(
      String phoneNumber) async {
    try {
      final querySnapshot = await _db
          .collection('Users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      final userDoc = querySnapshot.docs.first;
      UserModel currentUser = UserModel.fromMap(userDoc.data(), userDoc.id);
      return currentUser;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await _db
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .update(user.toMap());
    } catch (error) {
      rethrow;
    }
  }
}
