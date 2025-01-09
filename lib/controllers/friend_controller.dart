import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/DB/friend_local_crud.dart';
import 'package:hedieaty/models/Firestore/event_firestore_crud.dart';
import 'package:hedieaty/models/Firestore/freind_firestore_crud.dart';
import 'package:hedieaty/models/Firestore/user_firestore_crud.dart';
import 'package:hedieaty/models/model/friend.dart';

class FriendController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<Friend?> addFriendsUsingPhoneNumber(String phoneNumber) async {
    try {
      final retrievedUser =
          await UserFirestoreCRUD.retrieveUserByPhoneNumber(phoneNumber);
      if (retrievedUser == null ||
          retrievedUser.firestoreId == _auth.currentUser!.uid) {
        return null;
      }
      final friend = Friend(
        friendId: retrievedUser.firestoreId!,
        userId: _auth.currentUser!.uid,
        name: retrievedUser.name,
      );
      FreindFirestoreCrud.addFriend(friend);
      FriendLocalCrud.addFriend(friend);
      return friend;
    } catch (error) {
      return null;
    }
  }

  static Future<List<Friend>> getMyFriends() async {
    try {
      final myFriends =
          await FreindFirestoreCrud.retrieveFriends(_auth.currentUser!.uid);
      if (myFriends.isEmpty) {
        return [];
      }
      return myFriends;
    } catch (error) {
      return [];
    }
  }

  static Future<int> getFriendEventCount(String id) async {
    // retreive friend events count along with eventcount for each friend
    return await EventFirestoreCrud.countUserEvents(id);
  }

  static Future<void> syncFriends(String userId) async {
    try {
      final firestoreFriend = await FreindFirestoreCrud.retrieveFriends(userId);
      var localFriend = await FriendLocalCrud.retrieveFriends(userId);
      if (firestoreFriend.isEmpty) return;
      localFriend ??= [];

      for (final friend in firestoreFriend) {
        if (!localFriend.contains(friend)) {
          FriendLocalCrud.addFriend(friend);
        }
      }
    } catch (error) {
      return;
    }
  }
}
