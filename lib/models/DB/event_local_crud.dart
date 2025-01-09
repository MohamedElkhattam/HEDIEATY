import 'package:hedieaty/models/DB/local_database_connection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hedieaty/models/model/event.dart';

class EventLocalCrud {
  static final Future<Database> _dbInstance =
      LocalDatabaseConnection().getInstance;

  static Future<int?> createEvent(Event event) async {
    try {
      final db = await _dbInstance;
      int id = await db.insert('Events', event.toLocalMap());
      return id;
    } catch (error) {
      return null;
    }
  }

  static Future<List<Event>?> retrieveEvents(int userId) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Events',
        where: 'event_owner_id = ?',
        whereArgs: [userId],
      );
      if (maps.isNotEmpty) {
        return maps.map((map) => Event.fromLocalMap(map)).toList();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<List<Event>?> retrieveEventsByFirestore(
      String firestoreId) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Events',
        where: 'firestore_id = ?',
        whereArgs: [firestoreId],
      );
      if (maps.isNotEmpty) {
        return maps.map((map) => Event.fromLocalMap(map)).toList();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<void> updateEvent(Event event) async {
    try {
      final db = await _dbInstance;
      await db.update(
        'Events',
        event.toLocalMap(),
        where: 'local_id = ?',
        whereArgs: [event.localId],
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> deleteEvent(int eventId) async {
    try {
      final db = await _dbInstance;
      await db.delete(
        'Events',
        where: 'local_id = ?',
        whereArgs: [eventId],
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<Event?> retrieveEventByLocalId(int id) async {
    try {
      final db = await _dbInstance;
      final List<Map<String, dynamic>> maps = await db.query(
        'Events',
        where: 'local_id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Event.fromLocalMap(maps.first);
      }
      return null;
    } catch (error) {
      return null;
    }
  }
}
