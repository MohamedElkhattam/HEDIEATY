import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/model/friend.dart';

class FreindFirestoreCrud {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addFriend(Friend friend) async {
    try {
      await _db.collection('Friends').add(friend.toMap());
      final userName = await UserController.getUserFullName(friend.userId!);
      await _db.collection('Friends').add(
            Friend(
              userId: friend.friendId,
              friendId: friend.userId,
              name: userName,
            ).toMap(),
          );
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Friend>> retrieveFriends(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('Friends')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Friend.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
