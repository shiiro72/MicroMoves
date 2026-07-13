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
  DatabaseHelper.databaseName = 'widget_test.db';

  setUp(() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.close();

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = p.join(dbPath, 'widget_test.db');
    await databaseFactory.deleteDatabase(path);
  });

  testWidgets('Dashboard renders and simulated notification triggers correctly', (WidgetTester tester) async {
    // Build and wait for real I/O within runAsync
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MicroMovesApp(),
        ),
      );
      // Wait for database initialization and loadData to complete
      await Future.delayed(const Duration(milliseconds: 600));
    });

    // Settle the frames
    await tester.pumpAndSettle();

    // Verify Title and Streak exist
    expect(find.text('MicroMoves'), findsOneWidget);
    expect(find.text('0 Day Streak'), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);
    expect(find.text('Skipped Today'), findsOneWidget);

    // Verify simulated notification doesn't exist yet
    expect(find.text('Time to move!'), findsNothing);

    // Tap on simulate reminder button
    final buttonFinder = find.text('Simulate Reminder Now');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Now, simulated notification overlay should be visible
    expect(find.text('Time to move!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Snooze'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Done and let database write complete within runAsync
    await tester.runAsync(() async {
      await tester.tap(find.text('Done'));
      // Wait for completeExercise DB write
      await Future.delayed(const Duration(milliseconds: 200));
    });

    await tester.pumpAndSettle();

    expect(find.text('Time to move!'), findsNothing);
    expect(find.text('1 Day Streak'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Completed count
  });
}
