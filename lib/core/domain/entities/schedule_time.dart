/// Domain-specific time representation for scheduling
/// Avoids Flutter dependency in domain layer
class ScheduleTime {
  final int hour;
  final int minute;

  const ScheduleTime({
    required this.hour,
    required this.minute,
  }) : assert(hour >= 0 && hour < 24),
       assert(minute >= 0 && minute < 60);

  /// Create from hour and minute
  const ScheduleTime.fromHoursMinutes({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24),
     assert(minute >= 0 && minute < 60);

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'hour': hour,
    'minute': minute,
  };

  factory ScheduleTime.fromJson(Map<String, dynamic> json) => ScheduleTime(
    hour: json['hour'] as int,
    minute: json['minute'] as int,
  );

  @override
  String toString() => 'ScheduleTime($hour:$minute)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleTime &&
           other.hour == hour &&
           other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}