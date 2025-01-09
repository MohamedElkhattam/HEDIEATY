import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/DB/local_database_connection.dart';
import 'package:hedieaty/models/model/friend.dart';
import 'package:sqflite/sqflite.dart';

class FriendLocalCrud {
  static final Future<Database> _dbInstance =
      LocalDatabaseConnection().getInstance;

  static Future<void> addFriend(Friend friend) async {
    try {
      final db = await _dbInstance;
      await db.insert('Friends', friend.toLocalMap());
      final userName = await UserController.getUserFullName(friend.userId!);
      await db.insert(
        'Friends',
        Friend(
          userId: friend.friendId,
          friendId: friend.userId,
          name: userName,
        ).toLocalMap(),
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<List<Friend>?> retrieveFriends(String userId) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Friends',
        where: 'user_firestore_id = ?',
        whereArgs: [userId],
      );
      if (maps.isNotEmpty) {
        return maps.map((map) => Friend.fromLocalMap(map)).toList();
      }
      return null;
    } catch (error) {
      return [];
    }
  }
}
