import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;

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
      },
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

  /// Triggers a simulated notification popup in-app
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
