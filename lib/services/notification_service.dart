import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
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
        } else if (action == 'snooze') {
          await dbHelper.snoozeExercise(exerciseId, name, category, value);
        } else if (action == 'skip') {
          await dbHelper.skipExercise(exerciseId, name, category, value);
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
    tz.initializeTimeZones();

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
