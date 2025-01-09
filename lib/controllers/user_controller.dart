import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/DB/user_local_crud.dart';
import 'package:hedieaty/models/Firestore/user_firestore_crud.dart';
import 'package:hedieaty/models/model/user_model.dart';

class UserController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isCurrentUser(String id) async {
    if (id == _auth.currentUser!.uid) {
      return true;
    }
    return false;
  }

  static Future<String> getUserFullName(String friendId) async {
    try {
      final user = await UserFirestoreCRUD.retrieveUserById(friendId);
      return user!.name;
    } catch (error) {
      return 'Unknown';
    }
  }

  static Future<UserModel> retrieveUserModel({userid}) async {
    if (userid == null) {
      final user =
          await UserFirestoreCRUD.retrieveUserById(_auth.currentUser!.uid);
      return user!;
    } else {
      final user = await UserFirestoreCRUD.retrieveUserById(userid);
      return user!;
    }
  }

  static Future<String> retrievCurrentUserId() async {
    return _auth.currentUser!.uid;
  }

  static Future<int> retrievCurrentUserLocalId() async {
    final userLocalId =
        await UserLocalCRUD.getUserLocalIdbyFireStoreId(_auth.currentUser!.uid);
    return userLocalId!;
  }

  static Future<UserModel?> updateUserData(
      String name, String phoneNumber, String bio) async {
    try {
      UserModel user = UserModel(
        name: name,
        email: _auth.currentUser!.email!,
        phoneNumber: phoneNumber,
        bio: bio,
      );
      await UserFirestoreCRUD.updateUser(user);
      return user;
    } catch (error) {
      return null;
    }
  }
}
