import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE health_records (
        id $idType,
        date $textType,
        steps $integerType,
        calories $integerType,
        water $integerType
      )
    ''');

    // Insert dummy records for testing
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    final dummyRecords = [
      {
        'date': '2024-11-25',
        'steps': 8500,
        'calories': 450,
        'water': 2000,
      },
      {
        'date': '2024-11-26',
        'steps': 10200,
        'calories': 520,
        'water': 2500,
      },
      {
        'date': '2024-11-27',
        'steps': 7800,
        'calories': 380,
        'water': 1800,
      },
    ];

    for (var record in dummyRecords) {
      await db.insert('health_records', record);
    }
  }

  // CREATE - Insert a new health record
  Future<HealthRecord> create(HealthRecord record) async {
    final db = await instance.database;
    final id = await db.insert('health_records', record.toMap());
    return record.copyWith(id: id);
  }

  // READ - Get a single record by ID
  Future<HealthRecord?> readRecord(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'health_records',
      columns: ['id', 'date', 'steps', 'calories', 'water'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return HealthRecord.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // READ - Get all records
  Future<List<HealthRecord>> readAllRecords() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('health_records', orderBy: orderBy);
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // READ - Search records by date
  Future<List<HealthRecord>> searchByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // READ - Get records for a specific date range
  Future<List<HealthRecord>> getRecordsByDateRange(
      String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.query(
      'health_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // UPDATE - Update an existing record
  Future<int> update(HealthRecord record) async {
    final db = await instance.database;
    return db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // DELETE - Delete a record
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get today's total statistics
  Future<Map<String, int>> getTodayStats(String todayDate) async {
    final records = await searchByDate(todayDate);
    
    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in records) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    return {
      'steps': totalSteps,
      'calories': totalCalories,
      'water': totalWater,
    };
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}