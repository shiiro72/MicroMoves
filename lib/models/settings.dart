class Settings {
  final int intervalMinutes; // e.g., 50
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "17:00"
  final List<int> activeWeekdays; // e.g., [1, 2, 3, 4, 5] (Monday=1, Sunday=7)
  final int snoozeDurationMinutes; // e.g., 5 or 10

  Settings({
    required this.intervalMinutes,
    required this.startTime,
    required this.endTime,
    required this.activeWeekdays,
    required this.snoozeDurationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'intervalMinutes': intervalMinutes,
      'startTime': startTime,
      'endTime': endTime,
      'activeWeekdays': activeWeekdays.join(','),
      'snoozeDurationMinutes': snoozeDurationMinutes,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    final weekdaysStr = map['activeWeekdays'] as String;
    final List<int> weekdays = weekdaysStr.isEmpty
        ? []
        : weekdaysStr.split(',').map((s) => int.parse(s)).toList();

    return Settings(
      intervalMinutes: map['intervalMinutes'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      activeWeekdays: weekdays,
      snoozeDurationMinutes: map['snoozeDurationMinutes'] as int,
    );
  }

  static Settings defaults() {
    return Settings(
      intervalMinutes: 50,
      startTime: "09:00",
      endTime: "17:00",
      activeWeekdays: [1, 2, 3, 4, 5], // Monday to Friday
      snoozeDurationMinutes: 10,
    );
  }

  Settings copyWith({
    int? intervalMinutes,
    String? startTime,
    String? endTime,
    List<int>? activeWeekdays,
    int? snoozeDurationMinutes,
  }) {
    return Settings(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      snoozeDurationMinutes: snoozeDurationMinutes ?? this.snoozeDurationMinutes,
    );
  }
}
