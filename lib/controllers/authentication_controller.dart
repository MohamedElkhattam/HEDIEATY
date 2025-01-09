import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/model/user_model.dart';
import 'package:hedieaty/models/DB/user_local_crud.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/friend_controller.dart';
import 'package:hedieaty/service/firebase_notification.dart';
import 'package:hedieaty/models/Firestore/user_firestore_crud.dart';

class AuthController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> intiateUserAfterLogin() async {
    final currentUser =
        await UserFirestoreCRUD.retrieveUserById(_auth.currentUser!.uid);
    return currentUser!;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = _auth.currentUser!.uid;
      final UserModel? myCurrentUserModel =
          await UserFirestoreCRUD.retrieveUserById(uid);
      if (myCurrentUserModel == null) {
        throw ('User not found in the FireStore.');
      }

      final userLocal = await UserLocalCRUD.getUserbyFireStoreId(uid);
      if (userLocal == null) {
        final localDBUser = await UserLocalCRUD.createUser(myCurrentUserModel);
        await EventController.syncEvents(uid, localDBUser);
        await FriendController.syncFriends(uid);
      }
      attachTokenToUser();
      return myCurrentUserModel;
    } on FirebaseAuthException catch (error) {
      throw (error.toString());
    } catch (error) {
      throw (error.toString());
    }
  }

  Future<String?> signUp(
      String name, String email, String password, String phoneNumber) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      UserModel user = UserModel(
        name: name,
        email: email,
        firestoreId: uid,
        phoneNumber: phoneNumber,
      );
      await UserFirestoreCRUD.addUser(user);
      await UserLocalCRUD.createUser(user);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<void> attachTokenToUser() async {
    final fcmToken = await FirebaseNotification().getFcmToken();
    UserFirestoreCRUD.attachFCMToUser(_auth.currentUser!.uid, fcmToken);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
