import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/exercise.dart';
import '../models/settings.dart';
import '../models/history_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String databaseName = 'micromoves.db';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // If running on desktop (Linux, MacOS, Windows) or in test mode, initialize sqflite_ffi
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows || Platform.environment.containsKey('FLUTTER_TEST'))) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createDB(db, version);
        },
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Create Exercises table
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        currentValue INTEGER NOT NULL,
        isTimeBased INTEGER NOT NULL DEFAULT 0,
        startValue INTEGER NOT NULL,
        incrementAmount INTEGER NOT NULL,
        incrementFrequency INTEGER NOT NULL,
        maxValue INTEGER NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        completionCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Create Settings table (single-row settings configuration)
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        intervalMinutes INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        activeWeekdays TEXT NOT NULL,
        snoozeDurationMinutes INTEGER NOT NULL
      )
    ''');

    // 3. Create History table
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseName TEXT NOT NULL,
        category TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        value INTEGER NOT NULL
      )
    ''');

    // 4. Prepopulate Settings
    final defaultSettings = Settings.defaults();
    await db.insert('settings', {
      'id': 1,
      ...defaultSettings.toMap(),
    });

    // 5. Prepopulate default Exercises
    final defaultExercises = _getDefaultExercises();
    for (var ex in defaultExercises) {
      await db.insert('exercises', ex.toMap());
    }
  }

  List<Exercise> _getDefaultExercises() {
    return [
      // Legs
      Exercise(
        name: 'Squats',
        category: 'Legs',
        currentValue: 12,
        isTimeBased: false,
        startValue: 12,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 30,
      ),
      Exercise(
        name: 'Lunges',
        category: 'Legs',
        currentValue: 10,
        isTimeBased: false,
        startValue: 10,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 24,
      ),
      Exercise(
        name: 'Calf Raises',
        category: 'Legs',
        currentValue: 15,
        isTimeBased: false,
        startValue: 15,
        incrementAmount: 3,
        incrementFrequency: 4,
        maxValue: 30,
      ),

      // Core
      Exercise(
        name: 'Plank',
        category: 'Core',
        currentValue: 30,
        isTimeBased: true,
        startValue: 30,
        incrementAmount: 5,
        incrementFrequency: 3,
        maxValue: 120,
      ),
      Exercise(
        name: 'Side Plank',
        category: 'Core',
        currentValue: 20,
        isTimeBased: true,
        startValue: 20,
        incrementAmount: 5,
        incrementFrequency: 3,
        maxValue: 60,
      ),

      // Upper Body
      Exercise(
        name: 'Wall Push-ups',
        category: 'Upper Body',
        currentValue: 10,
        isTimeBased: false,
        startValue: 10,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 25,
      ),
      Exercise(
        name: 'Shoulder Raises',
        category: 'Upper Body',
        currentValue: 12,
        isTimeBased: false,
        startValue: 12,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 25,
      ),
      Exercise(
        name: 'Shoulder Press',
        category: 'Upper Body',
        currentValue: 10,
        isTimeBased: false,
        startValue: 10,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 25,
      ),
      Exercise(
        name: 'Bicep Curls',
        category: 'Upper Body',
        currentValue: 12,
        isTimeBased: false,
        startValue: 12,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 30,
      ),

      // Mobility
      Exercise(
        name: 'Neck Stretch',
        category: 'Mobility',
        currentValue: 30,
        isTimeBased: true,
        startValue: 30,
        incrementAmount: 5,
        incrementFrequency: 3,
        maxValue: 60,
      ),
      Exercise(
        name: 'Chest Stretch',
        category: 'Mobility',
        currentValue: 30,
        isTimeBased: true,
        startValue: 30,
        incrementAmount: 5,
        incrementFrequency: 3,
        maxValue: 60,
      ),
      Exercise(
        name: 'Shoulder Circles',
        category: 'Mobility',
        currentValue: 20,
        isTimeBased: true,
        startValue: 20,
        incrementAmount: 5,
        incrementFrequency: 4,
        maxValue: 45,
      ),
      Exercise(
        name: 'Hip Stretch',
        category: 'Mobility',
        currentValue: 30,
        isTimeBased: true,
        startValue: 30,
        incrementAmount: 5,
        incrementFrequency: 3,
        maxValue: 60,
      ),

      // Cardio
      Exercise(
        name: 'Walk',
        category: 'Cardio',
        currentValue: 120, // 2 minutes
        isTimeBased: true,
        startValue: 120,
        incrementAmount: 30,
        incrementFrequency: 5,
        maxValue: 600, // 10 minutes
      ),
      Exercise(
        name: 'March in Place',
        category: 'Cardio',
        currentValue: 60, // 1 minute
        isTimeBased: true,
        startValue: 60,
        incrementAmount: 15,
        incrementFrequency: 5,
        maxValue: 300, // 5 minutes
      ),
    ];
  }

  // --- Database Operations ---

  // Exercises
  Future<List<Exercise>> getExercises() async {
    final db = await database;
    final maps = await db.query('exercises');
    return maps.map((m) => Exercise.fromMap(m)).toList();
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Settings
  Future<Settings> getSettings() async {
    final db = await database;
    final maps = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return Settings.fromMap(maps.first);
    }
    return Settings.defaults();
  }

  Future<int> updateSettings(Settings settings) async {
    final db = await database;
    return await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // History
  Future<List<HistoryEntry>> getHistory() async {
    final db = await database;
    final maps = await db.query('history', orderBy: 'timestamp DESC');
    return maps.map((m) => HistoryEntry.fromMap(m)).toList();
  }

  Future<int> insertHistoryEntry(HistoryEntry entry) async {
    final db = await database;
    return await db.insert('history', entry.toMap());
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }

  // Helper to fetch single exercise by ID
  Future<Exercise?> getExerciseById(int id) async {
    final db = await database;
    final maps = await db.query('exercises', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  // Direct operations for background isolate / app notifications
  Future<void> completeExercise(int exerciseId, String name, String category, int value) async {
    final ex = await getExerciseById(exerciseId);
    if (ex != null) {
      final newCount = ex.completionCount + 1;
      int newValue = ex.currentValue;

      // Progression logic:
      // "Increase: +incrementAmount reps/secs every incrementFrequency completions up to maxValue"
      if (ex.incrementFrequency > 0 && newCount % ex.incrementFrequency == 0) {
        newValue = ex.currentValue + ex.incrementAmount;
        if (newValue > ex.maxValue) {
          newValue = ex.maxValue;
        }
      }

      final updated = ex.copyWith(
        completionCount: newCount,
        currentValue: newValue,
      );
      await updateExercise(updated);
    }

    final entry = HistoryEntry(
      exerciseName: name,
      category: category,
      timestamp: DateTime.now().toIso8601String(),
      status: 'completed',
      value: value,
    );
    await insertHistoryEntry(entry);
  }

  Future<void> dismissExercise(int exerciseId, String name, String category, int value) async {
    final entry = HistoryEntry(
      exerciseName: name,
      category: category,
      timestamp: DateTime.now().toIso8601String(),
      status: 'dismissed',
      value: value,
    );
    await insertHistoryEntry(entry);
  }

  Future<void> skipExercise(int exerciseId, String name, String category, int value) async {
    final entry = HistoryEntry(
      exerciseName: name,
      category: category,
      timestamp: DateTime.now().toIso8601String(),
      status: 'skipped',
      value: value,
    );
    await insertHistoryEntry(entry);
  }

  Future<void> snoozeExercise(int exerciseId, String name, String category, int value) async {
    final entry = HistoryEntry(
      exerciseName: name,
      category: category,
      timestamp: DateTime.now().toIso8601String(),
      status: 'snoozed',
      value: value,
    );
    await insertHistoryEntry(entry);
  }

  // Close
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
