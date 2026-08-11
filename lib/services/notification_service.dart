import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;
import '../models/exercise.dart';
import '../models/settings.dart';
import 'exercise_selection_service.dart';
import 'database_helper.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final action = response.actionId; // 'done', 'snooze', 'skip', or null
  final payload = response.payload;
  if (payload != null && action != null) {
    final parts = payload.split('|');
    if (parts.length == 4) {
      final exerciseId = int.tryParse(parts[0]);
      final name = parts[1];
      final category = parts[2];
      final value = int.tryParse(parts[3]);
      if (exerciseId != null && value != null) {
        final dbHelper = DatabaseHelper.instance;
        if (action == 'done') {
          await dbHelper.completeExercise(exerciseId, name, category, value);
          try {
            final exercises = await dbHelper.getExercises();
            final settings = await dbHelper.getSettings();
            final history = await dbHelper.getHistory();
            String? lastEx;
            String? lastCat;
            if (history.isNotEmpty) {
              lastEx = history.first.exerciseName;
              lastCat = history.first.category;
            }
            final notificationService = NotificationService.instance;
            await notificationService.init();
            await notificationService.scheduleUpcomingReminders(
              exercises: exercises,
              settings: settings,
              lastExerciseName: lastEx,
              lastCategory: lastCat,
            );
          } catch (_) {}
        } else if (action == 'dismiss') {
          await dbHelper.dismissExercise(exerciseId, name, category, value);
          try {
            final exercises = await dbHelper.getExercises();
            final settings = await dbHelper.getSettings();
            final history = await dbHelper.getHistory();
            String? lastEx;
            String? lastCat;
            if (history.isNotEmpty) {
              lastEx = history.first.exerciseName;
              lastCat = history.first.category;
            }
            final notificationService = NotificationService.instance;
            await notificationService.init();
            await notificationService.scheduleUpcomingReminders(
              exercises: exercises,
              settings: settings,
              lastExerciseName: lastEx,
              lastCategory: lastCat,
            );
          } catch (_) {}
        } else if (action == 'snooze') {
          await dbHelper.snoozeExercise(exerciseId, name, category, value);
          try {
            final settings = await dbHelper.getSettings();
            final snoozeTime = DateTime.now().add(Duration(minutes: settings.snoozeDurationMinutes));
            final notificationService = NotificationService.instance;
            await notificationService.init();
            await notificationService.scheduleSnoozeNotification(
              exerciseId: exerciseId,
              name: name,
              category: category,
              value: value,
              scheduledTime: snoozeTime,
            );
            final exercises = await dbHelper.getExercises();
            final history = await dbHelper.getHistory();
            String? lastEx;
            String? lastCat;
            if (history.isNotEmpty) {
              lastEx = history.first.exerciseName;
              lastCat = history.first.category;
            }
            await notificationService.scheduleUpcomingReminders(
              exercises: exercises,
              settings: settings,
              lastExerciseName: lastEx,
              lastCategory: lastCat,
            );
          } catch (_) {}
        } else if (action == 'skip') {
          await dbHelper.skipExercise(exerciseId, name, category, value);
          try {
            final exercises = await dbHelper.getExercises();
            final settings = await dbHelper.getSettings();
            final history = await dbHelper.getHistory();
            String? lastEx;
            String? lastCat;
            if (history.isNotEmpty) {
              lastEx = history.first.exerciseName;
              lastCat = history.first.category;
            }
            final notificationService = NotificationService.instance;
            await notificationService.init();
            await notificationService.scheduleUpcomingReminders(
              exercises: exercises,
              settings: settings,
              lastExerciseName: lastEx,
              lastCategory: lastCat,
            );
          } catch (_) {}
        }
      }
    }
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // A simulated callback so we can simulate notification actions inside the app/UI.
  Function(String action, int exerciseId, String name, String category, int value)? onSimulatedActionTriggered;

  // Track if a reminder simulation is currently active
  ActiveSimulation? activeSimulation;

  NotificationService._init();

  Future<void> init() async {
    tz_init.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle background or inline notifications
        final action = response.actionId; // 'done', 'snooze', 'skip', or null
        final payload = response.payload;
        if (payload != null && action != null) {
          final parts = payload.split('|');
          if (parts.length == 4) {
            final exerciseId = int.tryParse(parts[0]);
            final name = parts[1];
            final category = parts[2];
            final value = int.tryParse(parts[3]);
            if (exerciseId != null && value != null) {
              activeSimulation = null; // Clear the simulated notification banner
              if (onSimulatedActionTriggered != null) {
                onSimulatedActionTriggered!(action, exerciseId, name, category, value);
              }
            }
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        try {
          await androidPlugin.requestNotificationsPermission();
        } catch (_) {}
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (_) {}
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'micromoves_reminders',
      'Reminders',
      channelDescription: 'Workday movement and stretch reminders',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('done', 'Done', cancelNotification: true),
        AndroidNotificationAction('snooze', 'Snooze', cancelNotification: true),
        AndroidNotificationAction('skip', 'Skip', cancelNotification: true),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'reminder_actions',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Triggers a simulated notification popup in-app and sends a real system-level local notification
  void triggerSimulatedNotification({
    required int exerciseId,
    required String name,
    required String category,
    required int value,
    required bool isTimeBased,
  }) {
    activeSimulation = ActiveSimulation(
      exerciseId: exerciseId,
      name: name,
      category: category,
      value: value,
      isTimeBased: isTimeBased,
    );

    final valueText = isTimeBased
        ? (value >= 60 ? '${value ~/ 60}m ${value % 60 > 0 ? "${value % 60}s" : ""}' : '${value}s')
        : '$value';

    showNotification(
      id: exerciseId,
      title: 'Time to move!',
      body: 'Do $valueText $name ($category)',
      payload: '$exerciseId|$name|$category|$value',
    ).catchError((_) {
      // Ignore notification errors in unsupported/headless/test environments
    });
  }

  void handleSimulatedAction(String action) {
    if (activeSimulation != null && onSimulatedActionTriggered != null) {
      final sim = activeSimulation!;
      activeSimulation = null; // Clear the simulation
      onSimulatedActionTriggered!(action, sim.exerciseId, sim.name, sim.category, sim.value);
    }
  }

  void dismissSimulation() {
    activeSimulation = null;
  }

  /// Calculates the upcoming scheduled notification dates based on settings and starting from now.
  List<DateTime> calculateUpcomingSlots({
    required int intervalMinutes,
    required String startTime,
    required String endTime,
    required List<int> activeWeekdays,
    required DateTime fromDateTime,
    int maxSlots = 50,
  }) {
    final List<DateTime> slots = [];

    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    if (startParts.length != 2 || endParts.length != 2) return [];

    final startHour = int.tryParse(startParts[0]) ?? 9;
    final startMinute = int.tryParse(startParts[1]) ?? 0;
    final endHour = int.tryParse(endParts[0]) ?? 17;
    final endMinute = int.tryParse(endParts[1]) ?? 0;

    if (endHour < startHour || (endHour == startHour && endMinute <= startMinute)) {
      return []; // Invalid schedule window
    }

    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
      if (slots.length >= maxSlots) break;

      final day = fromDateTime.add(Duration(days: dayOffset));
      final weekday = day.weekday; // 1 = Monday, 7 = Sunday

      if (!activeWeekdays.contains(weekday)) continue;

      final startWorkday = DateTime(day.year, day.month, day.day, startHour, startMinute);
      final endWorkday = DateTime(day.year, day.month, day.day, endHour, endMinute);

      var currentSlot = startWorkday;
      while (currentSlot.isBefore(endWorkday) || currentSlot.isAtSameMomentAs(endWorkday)) {
        if (slots.length >= maxSlots) break;

        if (currentSlot.isAfter(fromDateTime)) {
          slots.add(currentSlot);
        }
        currentSlot = currentSlot.add(Duration(minutes: intervalMinutes));
      }
    }

    return slots;
  }

  /// Adjusts a target date/time to a valid workday window
  DateTime adjustToValidWorkday({
    required DateTime baseTime,
    required String startTime,
    required String endTime,
    required List<int> activeWeekdays,
    required DateTime now,
  }) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startHour = int.tryParse(startParts[0]) ?? 9;
    final startMinute = int.tryParse(startParts[1]) ?? 0;
    final endHour = int.tryParse(endParts[0]) ?? 17;
    final endMinute = int.tryParse(endParts[1]) ?? 0;

    var current = baseTime.isBefore(now) ? now : baseTime;

    for (int i = 0; i < 14; i++) {
      final weekday = current.weekday;
      final startWorkday = DateTime(current.year, current.month, current.day, startHour, startMinute);
      final endWorkday = DateTime(current.year, current.month, current.day, endHour, endMinute);

      if (!activeWeekdays.contains(weekday)) {
        current = DateTime(current.year, current.month, current.day + 1, startHour, startMinute);
        continue;
      }

      if (current.isBefore(startWorkday)) {
        final candidate = startWorkday;
        return candidate.isAfter(now) ? candidate : now.add(const Duration(seconds: 1));
      } else if (current.isAfter(endWorkday)) {
        current = DateTime(current.year, current.month, current.day + 1, startHour, startMinute);
        continue;
      } else {
        return current.isAfter(now) ? current : now.add(const Duration(seconds: 1));
      }
    }

    return now.add(const Duration(seconds: 1));
  }

  /// Clears existing scheduled notifications and queues up to 50 randomized workday exercise reminders.
  Future<void> scheduleUpcomingReminders({
    required List<Exercise> exercises,
    required Settings settings,
    String? lastExerciseName,
    String? lastCategory,
  }) async {
    // 1. Fetch History
    final history = await DatabaseHelper.instance.getHistory();

    // 2. If previous notification didn't get a response (it is currently snoozed), DO NOT send/schedule another reminder
    if (history.isNotEmpty && history.first.status == 'snoozed') {
      try {
        await _localNotifications.cancel(id: 1000);
      } catch (_) {}
      return;
    }

    // 3. Otherwise, cancel existing regular (ID 1000) and snooze (ID 9999) notifications
    try {
      await _localNotifications.cancel(id: 1000);
      await _localNotifications.cancel(id: 9999);
    } catch (_) {}

    final enabledExercises = exercises.where((e) => e.isEnabled).toList();
    if (enabledExercises.isEmpty) return;

    final now = DateTime.now();

    // 4. Calculate next reminder time relative to response of previous one
    DateTime lastResponseTime = now;
    if (history.isNotEmpty) {
      final parsed = DateTime.tryParse(history.first.timestamp);
      if (parsed != null) {
        lastResponseTime = parsed;
      }
    }

    final targetTime = lastResponseTime.add(Duration(minutes: settings.intervalMinutes));
    final scheduledTime = adjustToValidWorkday(
      baseTime: targetTime,
      startTime: settings.startTime,
      endTime: settings.endTime,
      activeWeekdays: settings.activeWeekdays,
      now: now,
    );

    final selectionService = ExerciseSelectionService();
    final selected = selectionService.selectNextExercise(
      enabledExercises,
      lastExerciseName: lastExerciseName,
      lastCategory: lastCategory,
    );

    if (selected != null) {
      final valueText = selected.isTimeBased
          ? (selected.currentValue >= 60
              ? '${selected.currentValue ~/ 60}m ${selected.currentValue % 60 > 0 ? "${selected.currentValue % 60}s" : ""}'
              : '${selected.currentValue}s')
          : '${selected.currentValue}';

      final payload = '${selected.id}|${selected.name}|${selected.category}|${selected.currentValue}';
      tz.Location location;
      try {
        location = tz.local;
      } catch (_) {
        location = tz.UTC;
      }
      final tzDateTime = tz.TZDateTime.from(scheduledTime, location);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'micromoves_reminders',
        'Reminders',
        channelDescription: 'Workday movement and stretch reminders',
        importance: Importance.max,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('done', 'Done', cancelNotification: true),
          AndroidNotificationAction('snooze', 'Snooze', cancelNotification: true),
          AndroidNotificationAction('skip', 'Skip', cancelNotification: true),
        ],
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'reminder_actions',
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _localNotifications.zonedSchedule(
          id: 1000,
          title: 'Time to move!',
          body: 'Do $valueText ${selected.name} (${selected.category})',
          scheduledDate: tzDateTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {}
    }
  }

  /// Schedules a snooze notification for a single exercise.
  Future<void> scheduleSnoozeNotification({
    required int exerciseId,
    required String name,
    required String category,
    required int value,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'micromoves_reminders',
      'Reminders',
      channelDescription: 'Workday movement and stretch reminders',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('done', 'Done', cancelNotification: true),
        AndroidNotificationAction('snooze', 'Snooze', cancelNotification: true),
        AndroidNotificationAction('skip', 'Skip', cancelNotification: true),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'reminder_actions',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    bool isTimeBased = false;
    try {
      final ex = await DatabaseHelper.instance.getExerciseById(exerciseId);
      if (ex != null) {
        isTimeBased = ex.isTimeBased;
      }
    } catch (_) {}

    final valueText = isTimeBased
        ? (value >= 60 ? '${value ~/ 60}m ${value % 60 > 0 ? "${value % 60}s" : ""}' : '${value}s')
        : '$value';

    final payload = '$exerciseId|$name|$category|$value';
    tz.Location location;
    try {
      location = tz.local;
    } catch (_) {
      location = tz.UTC;
    }
    final tzDateTime = tz.TZDateTime.from(scheduledTime, location);

    try {
      await _localNotifications.zonedSchedule(
        id: 9999,
        title: 'Snoozed Reminder: Time to move!',
        body: 'Do $valueText $name ($category)',
        scheduledDate: tzDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (_) {}
  }
}

class ActiveSimulation {
  final int exerciseId;
  final String name;
  final String category;
  final int value;
  final bool isTimeBased;

  ActiveSimulation({
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.value,
    required this.isTimeBased,
  });
}
