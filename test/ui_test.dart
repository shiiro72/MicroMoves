import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:micromoves/main.dart';
import 'package:micromoves/services/database_helper.dart';
import 'package:micromoves/services/app_state.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  DatabaseHelper.databaseName = 'ui_test.db';

  setUp(() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.close();

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = p.join(dbPath, 'ui_test.db');
    await databaseFactory.deleteDatabase(path);
  });

  testWidgets('Navigation switches tabs and interacts correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MicroMovesApp(),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await tester.pumpAndSettle();

    // Verify initially on Dashboard Screen
    expect(find.text('Completed Today'), findsOneWidget);

    // Switch to Exercises screen
    await tester.tap(find.byIcon(Icons.fitness_center_outlined));
    await tester.pumpAndSettle();

    // Verify on Exercises screen
    expect(find.text('Squats'), findsOneWidget);
    expect(find.text('Lunges'), findsOneWidget);

    // Switch to History screen
    await tester.tap(find.byIcon(Icons.history_outlined));
    await tester.pumpAndSettle();

    // Verify empty history screen renders
    expect(find.text('No history yet'), findsOneWidget);

    // Switch to Settings screen
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify Settings screen displays
    expect(find.text('Work Start Time'), findsOneWidget);
    expect(find.text('Reminder Interval'), findsOneWidget);
  });
}
