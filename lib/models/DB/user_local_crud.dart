import 'package:hedieaty/models/DB/local_database_connection.dart';
import 'package:hedieaty/models/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalCRUD {
  static final Future<Database> _dbInstance =
      LocalDatabaseConnection().getInstance;

  static Future<int> createUser(UserModel user) async {
    final db = await _dbInstance;
    return await db.insert('Users', user.toLocalMap());
  }

  static Future<List<UserModel>> getAllUsers() async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> maps = await db.query('Users');
    return maps.map((map) => UserModel.fromLocalMap(map)).toList();
  }

  static Future<UserModel?> getUserById(int id) async {
    final db = await _dbInstance;
    final List<Map<String, dynamic>> maps =
        await db.query('Users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromLocalMap(maps.first);
    }
    return null;
  }

  static Future<UserModel?> getUserbyFireStoreId(String id) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps =
          await db.query('Users', where: 'firestore_id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return UserModel.fromLocalMap(maps.first);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<int?> getUserLocalIdbyFireStoreId(String id) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Users',
        columns: ['id'],
        where: 'firestore_id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first['id'] as int;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<int> updateUser(UserModel user) async {
    final db = await _dbInstance;
    return await db.update(
      'Users',
      user.toLocalMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<int> deleteUser(int id) async {
    final db = await _dbInstance;
    return await db.delete('Users', where: 'id = ?', whereArgs: [id]);
  }
}
