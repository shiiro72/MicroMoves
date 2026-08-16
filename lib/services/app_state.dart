import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../models/settings.dart';
import '../models/history_entry.dart';
import 'database_helper.dart';
import 'exercise_selection_service.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ExerciseSelectionService _selectionService = ExerciseSelectionService();
  final NotificationService _notificationService = NotificationService.instance;

  List<Exercise> _exercises = [];
  Settings _settings = Settings.defaults();
  List<HistoryEntry> _history = [];

  List<Exercise> get exercises => _exercises;
  Settings get settings => _settings;
  List<HistoryEntry> get history => _history;

  ActiveSimulation? get activeSimulation => _notificationService.activeSimulation;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await loadData();
    try {
      await _notificationService.init();
    } catch (_) {
      // Ignore initialization errors in headless test/non-supported environments
    }
    _notificationService.onSimulatedActionTriggered = (action, exerciseId, name, category, value) async {
      if (action == 'done') {
        await completeExercise(exerciseId, name, category, value);
      } else if (action == 'snooze') {
        await snoozeExercise(exerciseId, name, category, value);
      } else if (action == 'skip') {
        await skipExercise(exerciseId, name, category, value);
      } else if (action == 'dismiss') {
        await dismissExercise(exerciseId, name, category, value);
      }
    };
    await scheduleUpcomingReminders();
  }

  Future<void> loadData() async {
    try {
      _exercises = await _dbHelper.getExercises();
      _settings = await _dbHelper.getSettings();
      _history = await _dbHelper.getHistory();
      notifyListeners();
    } catch (_) {
      // Quietly continue
    }
  }

  // --- Exercise CRUD & Toggles ---

  Future<void> toggleExerciseEnabled(int id, bool isEnabled) async {
    final idx = _exercises.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final updated = _exercises[idx].copyWith(isEnabled: isEnabled);
      await _dbHelper.updateExercise(updated);
      _exercises[idx] = updated;
      await scheduleUpcomingReminders();
      notifyListeners();
    }
  }

  Future<void> saveExercise(Exercise exercise) async {
    if (exercise.id == null) {
      final id = await _dbHelper.insertExercise(exercise);
      _exercises.add(exercise.copyWith(id: id));
    } else {
      await _dbHelper.updateExercise(exercise);
      final idx = _exercises.indexWhere((e) => e.id == exercise.id);
      if (idx != -1) {
        _exercises[idx] = exercise;
      }
    }
    await scheduleUpcomingReminders();
    notifyListeners();
  }

  Future<void> deleteExercise(int id) async {
    await _dbHelper.deleteExercise(id);
    _exercises.removeWhere((e) => e.id == id);
    await scheduleUpcomingReminders();
    notifyListeners();
  }

  // --- Settings Update ---

  Future<void> updateSettings(Settings newSettings) async {
    await _dbHelper.updateSettings(newSettings);
    _settings = newSettings;
    await scheduleUpcomingReminders();
    notifyListeners();
  }

  // --- Reminder Action Operations ---

  /// Handles completion of an exercise, incrementing completion count and applying progression rules
  Future<void> completeExercise(int exerciseId, String name, String category, int value) async {
    await _dbHelper.completeExercise(exerciseId, name, category, value);
    await loadData();
    await scheduleUpcomingReminders();
  }

  Future<void> dismissExercise(int exerciseId, String name, String category, int value) async {
    await _dbHelper.dismissExercise(exerciseId, name, category, value);
    await loadData();
    await scheduleUpcomingReminders();
  }

  Future<void> skipExercise(int exerciseId, String name, String category, int value) async {
    await _dbHelper.skipExercise(exerciseId, name, category, value);
    await loadData();
    await scheduleUpcomingReminders();
  }

  Future<void> snoozeExercise(int exerciseId, String name, String category, int value) async {
    await _dbHelper.snoozeExercise(exerciseId, name, category, value);
    try {
      final snoozeTime = DateTime.now().add(Duration(minutes: _settings.snoozeDurationMinutes));
      await _notificationService.scheduleSnoozeNotification(
        exerciseId: exerciseId,
        name: name,
        category: category,
        value: value,
        scheduledTime: snoozeTime,
      );
    } catch (_) {}
    await loadData();
    await scheduleUpcomingReminders();
  }

  Future<void> clearHistory() async {
    await _dbHelper.clearHistory();
    _history.clear();
    await scheduleUpcomingReminders();
    notifyListeners();
  }

  /// Triggers a background reschedule of all upcoming reminders.
  Future<void> scheduleUpcomingReminders() async {
    try {
      String? lastExName;
      String? lastCategory;
      if (_history.isNotEmpty) {
        final lastRealEntry = _history.firstWhere(
          (e) => e.status == 'completed' || e.status == 'skipped',
          orElse: () => HistoryEntry(
            exerciseName: '',
            category: '',
            timestamp: '',
            status: '',
            value: 0,
          ),
        );
        if (lastRealEntry.exerciseName.isNotEmpty) {
          lastExName = lastRealEntry.exerciseName;
          lastCategory = lastRealEntry.category;
        }
      }

      await _notificationService.scheduleUpcomingReminders(
        exercises: _exercises,
        settings: _settings,
        lastExerciseName: lastExName,
        lastCategory: lastCategory,
      );
    } catch (_) {
      // Ignore in unsupported environments
    }
  }

  // --- Streak and Counts Calculations ---

  int get completedTodayCount {
    final today = DateTime.now();
    return _history.where((entry) {
      if (entry.status != 'completed') return false;
      final date = DateTime.tryParse(entry.timestamp);
      if (date == null) return false;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).length;
  }

  int get skippedTodayCount {
    final today = DateTime.now();
    return _history.where((entry) {
      if (entry.status != 'skipped') return false;
      final date = DateTime.tryParse(entry.timestamp);
      if (date == null) return false;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).length;
  }

  /// Calculates the current daily streak of consecutive days with at least one completion.
  int get currentStreak {
    if (_history.isEmpty) return 0;

    // Extract all completed dates, normalized to date-only (year, month, day)
    final completedDates = _history
        .where((entry) => entry.status == 'completed')
        .map((entry) {
          final parsed = DateTime.tryParse(entry.timestamp);
          if (parsed == null) return null;
          return DateTime(parsed.year, parsed.month, parsed.day);
        })
        .whereType<DateTime>()
        .toSet()
        .toList();

    if (completedDates.isEmpty) return 0;

    // Sort descending (most recent first)
    completedDates.sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized = todayNormalized.subtract(const Duration(days: 1));

    // If the most recent completion is neither today nor yesterday, the streak is broken
    final newestCompletedDate = completedDates.first;
    if (newestCompletedDate != todayNormalized && newestCompletedDate != yesterdayNormalized) {
      return 0;
    }

    int streak = 0;
    var currentCheckDate = newestCompletedDate;

    for (var date in completedDates) {
      if (date == currentCheckDate) {
        streak++;
        // Prepare to check the previous day
        currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(currentCheckDate)) {
        // There is a gap in the consecutive days, streak ends here.
        break;
      }
    }

    return streak;
  }

  // --- Trigger/Simulation Methods ---

  /// Randomly selects an appropriate exercise and triggers notification simulation.
  void triggerReminder() {
    String? lastExName;
    String? lastCategory;

    // Try to find the most recent non-snoozed reminder from history for selection rules
    final lastRealEntry = _history.firstWhere(
      (e) => e.status == 'completed' || e.status == 'skipped',
      orElse: () => HistoryEntry(
        exerciseName: '',
        category: '',
        timestamp: '',
        status: '',
        value: 0,
      ),
    );

    if (lastRealEntry.exerciseName.isNotEmpty) {
      lastExName = lastRealEntry.exerciseName;
      lastCategory = lastRealEntry.category;
    }

    final selected = _selectionService.selectNextExercise(
      _exercises,
      lastExerciseName: lastExName,
      lastCategory: lastCategory,
    );

    if (selected != null) {
      _notificationService.triggerSimulatedNotification(
        exerciseId: selected.id ?? 0,
        name: selected.name,
        category: selected.category,
        value: selected.currentValue,
        isTimeBased: selected.isTimeBased,
      );
      notifyListeners();
    }
  }

  void handleSimulatedAction(String action) {
    _notificationService.handleSimulatedAction(action);
    notifyListeners();
  }

  void dismissSimulation() {
    _notificationService.dismissSimulation();
    notifyListeners();
  }
}
