import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:micromoves/services/database_helper.dart';
import 'package:micromoves/models/exercise.dart';
import 'package:micromoves/models/history_entry.dart';

void main() {
  // Initialize sqflite_common_ffi for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  DatabaseHelper.databaseName = 'database_test.db';

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      await dbHelper.close();

      // Delete existing database file to get a completely fresh setup
      final dbPath = await databaseFactory.getDatabasesPath();
      final path = p.join(dbPath, 'database_test.db');
      await databaseFactory.deleteDatabase(path);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Initial database prepopulation', () async {
      final exercises = await dbHelper.getExercises();
      final settings = await dbHelper.getSettings();
      final history = await dbHelper.getHistory();

      expect(exercises.isNotEmpty, true);
      // Verify there are common exercises like Squats
      final squats = exercises.firstWhere((e) => e.name == 'Squats');
      expect(squats.category, 'Legs');
      expect(squats.currentValue, 12);

      expect(settings.intervalMinutes, 50);
      expect(settings.startTime, "09:00");
      expect(history.isEmpty, true);
    });

    test('Insert and update custom exercise', () async {
      final custom = Exercise(
        name: 'Super Jumps',
        category: 'Cardio',
        currentValue: 5,
        startValue: 5,
        incrementAmount: 1,
        incrementFrequency: 2,
        maxValue: 10,
      );

      final id = await dbHelper.insertExercise(custom);
      expect(id > 0, true);

      var exercises = await dbHelper.getExercises();
      final added = exercises.firstWhere((e) => e.name == 'Super Jumps');
      expect(added.id, id);
      expect(added.isEnabled, true);

      // Update exercise
      final updated = added.copyWith(isEnabled: false, currentValue: 8);
      await dbHelper.updateExercise(updated);

      exercises = await dbHelper.getExercises();
      final retrievedUpdated = exercises.firstWhere((e) => e.id == id);
      expect(retrievedUpdated.isEnabled, false);
      expect(retrievedUpdated.currentValue, 8);
    });

    test('Update settings', () async {
      final current = await dbHelper.getSettings();
      final modified = current.copyWith(intervalMinutes: 45, snoozeDurationMinutes: 15);

      await dbHelper.updateSettings(modified);
      final retrieved = await dbHelper.getSettings();

      expect(retrieved.intervalMinutes, 45);
      expect(retrieved.snoozeDurationMinutes, 15);
    });

    test('Insert and clear history entries', () async {
      final entry = HistoryEntry(
        exerciseName: 'Squats',
        category: 'Legs',
        timestamp: DateTime.now().toIso8601String(),
        status: 'completed',
        value: 12,
      );

      await dbHelper.insertHistoryEntry(entry);
      var history = await dbHelper.getHistory();
      expect(history.length, 1);
      expect(history.first.exerciseName, 'Squats');

      await dbHelper.clearHistory();
      history = await dbHelper.getHistory();
      expect(history.isEmpty, true);
    });

    test('completeExercise progression and history entry in database', () async {
      final exercises = await dbHelper.getExercises();
      final squats = exercises.firstWhere((e) => e.name == 'Squats');

      expect(squats.currentValue, 12);
      expect(squats.completionCount, 0);

      // Call completeExercise
      await dbHelper.completeExercise(squats.id!, squats.name, squats.category, squats.currentValue);

      final updatedExercises = await dbHelper.getExercises();
      final updatedSquats = updatedExercises.firstWhere((e) => e.name == 'Squats');
      expect(updatedSquats.completionCount, 1);

      final history = await dbHelper.getHistory();
      expect(history.length, 1);
      expect(history.first.exerciseName, 'Squats');
      expect(history.first.status, 'completed');
    });

    test('skipExercise and snoozeExercise database records', () async {
      final exercises = await dbHelper.getExercises();
      final squats = exercises.firstWhere((e) => e.name == 'Squats');

      await dbHelper.skipExercise(squats.id!, squats.name, squats.category, squats.currentValue);
      await dbHelper.snoozeExercise(squats.id!, squats.name, squats.category, squats.currentValue);

      final history = await dbHelper.getHistory();
      expect(history.length, 2);
      expect(history[0].status, 'snoozed');
      expect(history[1].status, 'skipped');
    });
  });
}
