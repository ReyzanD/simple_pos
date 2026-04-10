import 'package:simple_pos/core/constants/backup_constants.dart';
import 'package:simple_pos/core/domain/entities/schedule_time.dart';
import 'backup_config.dart';

/// Represents a scheduled backup configuration
class BackupSchedule {
  final int id;
  final String name;
  final BackupFrequency frequency;
  final ScheduleTime time;
  final BackupConfig config;
  final bool isActive;

  const BackupSchedule({
    required this.id,
    required this.name,
    required this.frequency,
    required this.time,
    required this.config,
    this.isActive = true,
  });

  /// Calculate next scheduled time
  DateTime getNextScheduledTime(DateTime from) {
    final scheduled = DateTime(
      from.year,
      from.month,
      from.day,
      time.hour,
      time.minute,
    );

    switch (frequency) {
      case BackupFrequency.daily:
        if (scheduled.isBefore(from)) {
          return scheduled.add(const Duration(days: 1));
        }
        return scheduled;

      case BackupFrequency.weekly:
        // For weekly backups, we'll schedule it for the same time every Sunday
        // This is a simplification - in a real app you might want more control
        var next = scheduled;
        while (next.weekday != DateTime.sunday || next.isBefore(from)) {
          next = next.add(const Duration(days: 1));
        }
        return next;

      case BackupFrequency.monthly:
        // Find next occurrence of day of month
        var next = scheduled;
        if (next.day != 1 || next.isBefore(from)) {
          // Move to next month, first day at the scheduled time
          final nextMonth = next.month < 12
              ? next.month + 1
              : 1;
          final nextYear = next.month < 12 ? next.year : next.year + 1;

          next = DateTime(
            nextYear,
            nextMonth,
            1, // First day of month
            time.hour,
            time.minute,
          );
        }
        return next;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency.name,
      'hour': time.hour,
      'minute': time.minute,
      'config': config.toJson(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory BackupSchedule.fromJson(Map<String, dynamic> json) {
    return BackupSchedule(
      id: json['id'] as int,
      name: json['name'] as String,
      frequency: BackupFrequency.values.firstWhere((e) => e.name == json['frequency']),
      time: ScheduleTime(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      config: BackupConfig.fromJson(json['config'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool,
    );
  }

  @override
  String toString() =>
      'BackupSchedule(id: $id, name: $name, frequency: $frequency, '
      'time: $time, active: $isActive)';
}