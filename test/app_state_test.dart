import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:micromoves/services/database_helper.dart';
import 'package:micromoves/services/app_state.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  DatabaseHelper.databaseName = 'app_state_test.db';

  group('AppState Tests', () {
    late AppState appState;

    setUp(() async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.close();

      // Delete existing database file to get a completely fresh setup
      final dbPath = await databaseFactory.getDatabasesPath();
      final path = p.join(dbPath, 'app_state_test.db');
      await databaseFactory.deleteDatabase(path);

      appState = AppState();
      // Wait for async AppState init
      await Future.delayed(const Duration(milliseconds: 150));
    });

    test('Progression logic works correctly', () async {
      final exercises = appState.exercises;
      final squats = exercises.firstWhere((e) => e.name == 'Squats');

      // Squats default currentValue: 12, incrementAmount: 2, incrementFrequency: 5
      expect(squats.currentValue, 12);
      expect(squats.completionCount, 0);

      // Complete 4 times
      for (int i = 0; i < 4; i++) {
        await appState.completeExercise(squats.id!, squats.name, squats.category, squats.currentValue);
      }

      var updatedSquats = appState.exercises.firstWhere((e) => e.name == 'Squats');
      expect(updatedSquats.completionCount, 4);
      expect(updatedSquats.currentValue, 12); // No increment yet

      // 5th completion should trigger progression increment (+2)
      await appState.completeExercise(squats.id!, squats.name, squats.category, squats.currentValue);
      updatedSquats = appState.exercises.firstWhere((e) => e.name == 'Squats');
      expect(updatedSquats.completionCount, 5);
      expect(updatedSquats.currentValue, 14);
    });

    test('Streak calculations work correctly', () async {
      // Initially 0 streak
      expect(appState.currentStreak, 0);

      // Insert completion for today
      await appState.completeExercise(1, 'Squats', 'Legs', 12);
      expect(appState.currentStreak, 1);
      expect(appState.completedTodayCount, 1);
    });
  });
}
