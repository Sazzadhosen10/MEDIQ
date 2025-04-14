import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'medication_reminder_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Set version to 3 to include the createdTime column.
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Create the database with all columns.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications(
        id TEXT PRIMARY KEY,
        userId TEXT,
        name TEXT,
        dosage TEXT,
        hour INTEGER,
        minute INTEGER,
        isActive INTEGER,
        createdTime TEXT
      )
    ''');
  }

  // Migration method that runs when an upgrade is detected.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Check if the 'createdTime' column already exists.
      List<Map<String, dynamic>> columns =
          await db.rawQuery("PRAGMA table_info(medications)");
      bool createdTimeExists =
          columns.any((col) => col['name'] == 'createdTime');
      if (!createdTimeExists) {
        // Add the createdTime column.
        await db
            .execute('ALTER TABLE medications ADD COLUMN createdTime TEXT;');
        // Set default values for existing rows.
        await db.execute(
          'UPDATE medications SET createdTime = ? WHERE createdTime IS NULL;',
          [DateTime.now().toIso8601String()],
        );
      }
    }
  }

  /// Insert a new MedicationReminder record.
  Future<void> insertMedication(MedicationReminder reminder) async {
    final db = await instance.database;
    await db.insert(
      'medications',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all medications for a specific user.
  Future<List<MedicationReminder>> getMedicationsByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'medications',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((json) => MedicationReminder.fromMap(json)).toList();
  }

  /// Retrieve all medications (optional).
  Future<List<MedicationReminder>> getAllMedications() async {
    final db = await instance.database;
    final result = await db.query('medications');
    return result.map((json) => MedicationReminder.fromMap(json)).toList();
  }

  /// Delete a medication record by id.
  Future<void> deleteMedication(String id) async {
    final db = await instance.database;
    await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
