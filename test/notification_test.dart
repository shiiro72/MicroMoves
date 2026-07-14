import 'package:flutter_test/flutter_test.dart';
import 'package:micromoves/services/notification_service.dart';
import 'package:micromoves/models/settings.dart';
import 'package:micromoves/models/exercise.dart';

void main() {
  group('NotificationService Slots Calculation Tests', () {
    final notificationService = NotificationService.instance;

    test('Calculates slots correctly within a standard workday', () {
      // Wednesday, Oct 23, 2024, 10:15 AM
      final fromDateTime = DateTime(2024, 10, 23, 10, 15);

      final slots = notificationService.calculateUpcomingSlots(
        intervalMinutes: 50,
        startTime: '09:00',
        endTime: '17:00',
        activeWeekdays: [3], // Only Wednesday
        fromDateTime: fromDateTime,
        maxSlots: 20,
      );

      // Over 14 days, there are 2 Wednesdays.
      // Wednesday Oct 23 (after 10:15):
      // 10:40, 11:30, 12:20, 13:10, 14:00, 14:50, 15:40, 16:30 (8 slots)
      // Wednesday Oct 30 (all slots):
      // 09:00, 09:50, 10:40, 11:30, 12:20, 13:10, 14:00, 14:50, 15:40, 16:30 (10 slots)
      // Total slots = 18.
      expect(slots.length, 18);
      expect(slots[0], DateTime(2024, 10, 23, 10, 40));
      expect(slots[17], DateTime(2024, 10, 30, 16, 30));
    });

    test('Excludes non-active weekdays', () {
      // Wednesday, Oct 23, 2024, 10:15 AM
      final fromDateTime = DateTime(2024, 10, 23, 10, 15);

      final slots = notificationService.calculateUpcomingSlots(
        intervalMinutes: 60,
        startTime: '09:00',
        endTime: '17:00',
        activeWeekdays: [4], // Thursday only
        fromDateTime: fromDateTime,
        maxSlots: 20,
      );

      // Thursday is Oct 24 and Oct 31.
      // Active slots per Thursday (09:00 to 17:00, interval 60):
      // 09:00, 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00 (9 slots each)
      // Total slots = 18.
      expect(slots.length, 18);
      expect(slots[0], DateTime(2024, 10, 24, 9, 0));
      expect(slots[17], DateTime(2024, 10, 31, 17, 0));
    });

    test('Caps at maxSlots correctly', () {
      // Wednesday, Oct 23, 2024, 10:15 AM
      final fromDateTime = DateTime(2024, 10, 23, 10, 15);

      final slots = notificationService.calculateUpcomingSlots(
        intervalMinutes: 60,
        startTime: '09:00',
        endTime: '17:00',
        activeWeekdays: [1, 2, 3, 4, 5, 6, 7], // Every day active
        fromDateTime: fromDateTime,
        maxSlots: 5,
      );

      expect(slots.length, 5);
    });

    test('Returns empty if invalid workday range is provided', () {
      final fromDateTime = DateTime(2024, 10, 23, 10, 15);

      final slots = notificationService.calculateUpcomingSlots(
        intervalMinutes: 50,
        startTime: '17:00',
        endTime: '09:00', // Invalid: end < start
        activeWeekdays: [3],
        fromDateTime: fromDateTime,
      );

      expect(slots.isEmpty, true);
    });
  });

  group('NotificationService Scheduling Integration Tests', () {
    test('scheduleUpcomingReminders executes without error', () async {
      final notificationService = NotificationService.instance;
      final exercises = [
        Exercise(
          id: 1,
          name: 'Squats',
          category: 'Legs',
          currentValue: 12,
          startValue: 12,
          incrementAmount: 2,
          incrementFrequency: 5,
          maxValue: 30,
        ),
      ];
      final settings = Settings.defaults();

      expect(
        () async => await notificationService.scheduleUpcomingReminders(
          exercises: exercises,
          settings: settings,
        ),
        returnsNormally,
      );
    });

    test('scheduleSnoozeNotification executes without error', () async {
      final notificationService = NotificationService.instance;
      expect(
        () async => await notificationService.scheduleSnoozeNotification(
          exerciseId: 1,
          name: 'Squats',
          category: 'Legs',
          value: 12,
          scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
        ),
        returnsNormally,
      );
    });
  });
}
