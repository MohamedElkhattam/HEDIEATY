import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseConnection {
  static Database? _instance;

  Future<Database> get getInstance async {
    _instance ??= await _initalDb();
    return _instance!;
  } // Singleton Design Pattern for allowing one instance of the DB

  static Future<Database> _initalDb() async {
    String path = join(await getDatabasesPath(), 'Hedieaty.db');
    // getDatabasesPath: Gets the default DB location to be stored on phone memory
    return openDatabase(path,
        onCreate: _onCreate, version: 5, onUpgrade: _onUpgrade);
  }

  static _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Changing version number triggers the onUpgrade
    if (oldVersion < newVersion) {
      // Drop the old table
      await db.execute('DROP TABLE IF EXISTS Friends');

      // Create the new table with the updated schema
      await db.execute('''
     CREATE TABLE Friends (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_firestore_id TEXT,
      friend_firestore_id TEXT,
      name TEXT NOT NULL
    )
    ''');
    }
  }

  static _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firestore_id TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      phone_number TEXT UNIQUE NOT NULL,
      bio TEXT ,
      preferences TEXT
    )
    ''');

    await db.execute('''
   CREATE TABLE Friends (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_firestore_id TEXT,
      friend_firestore_id TEXT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE Events (
      local_id INTEGER PRIMARY KEY AUTOINCREMENT,
      firestore_id TEXT UNIQUE,
      event_owner_firestore_id TEXT,
      event_owner_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      FOREIGN KEY(event_owner_id) REFERENCES Users(id)
    )
    ''');

    await db.execute('''
     CREATE TABLE Gifts (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestore_id TEXT UNIQUE,
        pledged_by TEXT,
        event_id TEXT,
        gift_ownername TEXT,
        event_local_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        image_path TEXT,
        FOREIGN KEY(event_local_id) REFERENCES Events(local_id)
      )
    ''');
  }
}
