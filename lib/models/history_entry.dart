class HistoryEntry {
  final int? id;
  final String exerciseName;
  final String category;
  final String timestamp; // ISO-8601 String
  final String status; // 'completed', 'skipped', 'snoozed'
  final int value; // reps or seconds achieved

  HistoryEntry({
    this.id,
    required this.exerciseName,
    required this.category,
    required this.timestamp,
    required this.status,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'exerciseName': exerciseName,
      'category': category,
      'timestamp': timestamp,
      'status': status,
      'value': value,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as int?,
      exerciseName: map['exerciseName'] as String,
      category: map['category'] as String,
      timestamp: map['timestamp'] as String,
      status: map['status'] as String,
      value: map['value'] as int,
    );
  }
}
