// lib/model/notification_settings_model.dart

class NotificationSettings {
  final bool startOfDayEnabled;
  final bool endOfDayEnabled;
  final int wakeUpHour;
  final int wakeUpMinute;
  final int sleepHour;
  final int sleepMinute;
  final DateTime? lastUpdated;

  const NotificationSettings({
    required this.startOfDayEnabled,
    required this.endOfDayEnabled,
    required this.wakeUpHour,
    required this.wakeUpMinute,
    required this.sleepHour,
    required this.sleepMinute,
    this.lastUpdated,
  });

  /// Factory constructor to create from stored data
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      startOfDayEnabled: map['startOfDayEnabled'] ?? true,
      endOfDayEnabled: map['endOfDayEnabled'] ?? true,
      wakeUpHour: map['wakeUpHour'] ?? 8,
      wakeUpMinute: map['wakeUpMinute'] ?? 0,
      sleepHour: map['sleepHour'] ?? 23,
      sleepMinute: map['sleepMinute'] ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'startOfDayEnabled': startOfDayEnabled,
      'endOfDayEnabled': endOfDayEnabled,
      'wakeUpHour': wakeUpHour,
      'wakeUpMinute': wakeUpMinute,
      'sleepHour': sleepHour,
      'sleepMinute': sleepMinute,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Get formatted wake up time string
  String get wakeUpTimeString {
    final hour = wakeUpHour.toString().padLeft(2, '0');
    final minute = wakeUpMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted sleep time string
  String get sleepTimeString {
    final hour = sleepHour.toString().padLeft(2, '0');
    final minute = sleepMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Create a copy with updated values
  NotificationSettings copyWith({
    bool? startOfDayEnabled,
    bool? endOfDayEnabled,
    int? wakeUpHour,
    int? wakeUpMinute,
    int? sleepHour,
    int? sleepMinute,
    DateTime? lastUpdated,
  }) {
    return NotificationSettings(
      startOfDayEnabled: startOfDayEnabled ?? this.startOfDayEnabled,
      endOfDayEnabled: endOfDayEnabled ?? this.endOfDayEnabled,
      wakeUpHour: wakeUpHour ?? this.wakeUpHour,
      wakeUpMinute: wakeUpMinute ?? this.wakeUpMinute,
      sleepHour: sleepHour ?? this.sleepHour,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Default notification settings
  static const NotificationSettings defaultSettings = NotificationSettings(
    startOfDayEnabled: true,
    endOfDayEnabled: true,
    wakeUpHour: 8,
    wakeUpMinute: 0,
    sleepHour: 23,
    sleepMinute: 0,
  );

  @override
  String toString() {
    return 'NotificationSettings(startOfDay: $startOfDayEnabled, endOfDay: $endOfDayEnabled, wakeUp: $wakeUpTimeString, sleep: $sleepTimeString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.startOfDayEnabled == startOfDayEnabled &&
        other.endOfDayEnabled == endOfDayEnabled &&
        other.wakeUpHour == wakeUpHour &&
        other.wakeUpMinute == wakeUpMinute &&
        other.sleepHour == sleepHour &&
        other.sleepMinute == sleepMinute;
  }

  @override
  int get hashCode {
    return Object.hash(
      startOfDayEnabled,
      endOfDayEnabled,
      wakeUpHour,
      wakeUpMinute,
      sleepHour,
      sleepMinute,
    );
  }
}
