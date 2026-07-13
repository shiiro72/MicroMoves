class Exercise {
  final int? id;
  final String name;
  final String category;
  final int currentValue; // repetitions or duration in seconds/minutes
  final bool isTimeBased; // whether unit is reps or seconds
  final int startValue;
  final int incrementAmount;
  final int incrementFrequency; // complete how many times to trigger increment
  final int maxValue;
  final bool isEnabled;
  final int completionCount; // keeps track of completed times for progression

  Exercise({
    this.id,
    required this.name,
    required this.category,
    required this.currentValue,
    this.isTimeBased = false,
    required this.startValue,
    required this.incrementAmount,
    required this.incrementFrequency,
    required this.maxValue,
    this.isEnabled = true,
    this.completionCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'currentValue': currentValue,
      'isTimeBased': isTimeBased ? 1 : 0,
      'startValue': startValue,
      'incrementAmount': incrementAmount,
      'incrementFrequency': incrementFrequency,
      'maxValue': maxValue,
      'isEnabled': isEnabled ? 1 : 0,
      'completionCount': completionCount,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      currentValue: map['currentValue'] as int,
      isTimeBased: (map['isTimeBased'] as int) == 1,
      startValue: map['startValue'] as int,
      incrementAmount: map['incrementAmount'] as int,
      incrementFrequency: map['incrementFrequency'] as int,
      maxValue: map['maxValue'] as int,
      isEnabled: (map['isEnabled'] as int) == 1,
      completionCount: map['completionCount'] as int,
    );
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    int? currentValue,
    bool? isTimeBased,
    int? startValue,
    int? incrementAmount,
    int? incrementFrequency,
    int? maxValue,
    bool? isEnabled,
    int? completionCount,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentValue: currentValue ?? this.currentValue,
      isTimeBased: isTimeBased ?? this.isTimeBased,
      startValue: startValue ?? this.startValue,
      incrementAmount: incrementAmount ?? this.incrementAmount,
      incrementFrequency: incrementFrequency ?? this.incrementFrequency,
      maxValue: maxValue ?? this.maxValue,
      isEnabled: isEnabled ?? this.isEnabled,
      completionCount: completionCount ?? this.completionCount,
    );
  }
}
