import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecordingDB {
  static final RecordingDB instance = RecordingDB._init();
  static Database? _database;

  RecordingDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recordings.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const recordingTable = '''
      CREATE TABLE recordings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        accelerometerData TEXT,
        gyroscopeData TEXT,
        linearAccelerationData TEXT
      )
    ''';

    await db.execute(recordingTable);
  }

  Future<int> insertRecording(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('recordings', data);
  }

  Future<List<Map<String, dynamic>>> fetchRecordings() async {
    final db = await instance.database;
    return await db.query('recordings');
  }

  Future<int> deleteRecording(int id) async {
    final db = await instance.database;
    return await db.delete('recordings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
