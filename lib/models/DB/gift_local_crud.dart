import 'dart:developer';
import 'package:hedieaty/models/DB/local_database_connection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hedieaty/models/model/gift.dart';

class GiftLocalCrud {
  static final Future<Database> _dbInstance =
      LocalDatabaseConnection().getInstance;

  static Future<int?> createGift(Gift gift) async {
    try {
      final db = await _dbInstance;
      int id = await db.insert('Gifts', gift.toLocalMap());
      return id;
    } catch (error) {
      return null;
    }
  }

  static Future<List<Gift>?> retrieveGiftsByEventFirestoreId(
      String eventId) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Gifts',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );

      if (maps.isNotEmpty) {
        return maps.map((map) => Gift.fromLocalMap(map)).toList();
      }
      return null;
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<List<Gift>?> retrieveGiftsByEventLocalId(int eventId) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Gifts',
        where: 'event_local_id = ?',
        whereArgs: [eventId],
      );

      if (maps.isNotEmpty) {
        return maps.map((map) => Gift.fromLocalMap(map)).toList();
      }
      return null;
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<void> updateGift(Gift gift) async {
    try {
      final db = await _dbInstance;
      await db.update(
        'Gifts',
        gift.toLocalMap(),
        where: 'local_id = ?',
        whereArgs: [gift.localId],
      );
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  static Future<void> deleteGift(int giftId) async {
    try {
      final db = await LocalDatabaseConnection().getInstance;
      await db.delete(
        'Gifts',
        where: 'local_id = ?',
        whereArgs: [giftId],
      );
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<Gift?> retrieveGiftByLocalId(int id) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Gifts',
        where: 'local_id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Gift.fromLocalMap(maps.first);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<void> giftPledge(String giftId, String statusName) async {
    try {
      final db = await _dbInstance;
      await db.update(
        'Gifts',
        {'status': statusName},
        where: 'firestore_id = ?',
        whereArgs: [giftId],
      );
    } catch (error) {
      log(error.toString());
      throw error.toString();
    }
  }
}
