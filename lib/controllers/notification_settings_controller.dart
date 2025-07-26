// lib/controllers/notification_settings_controller.dart
// This controller will be used by the settings page to manage notification preferences

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/model/notification_settings_model.dart';
import 'package:streakly/services/notification_service.dart';

/// Provider for notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsController, NotificationSettings>(
      (ref) {
        return NotificationSettingsController();
      },
    );

class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController()
    : super(NotificationSettings.defaultSettings) {
    _loadSettings();
  }

  /// Load notification settings from storage
  Future<void> _loadSettings() async {
    try {
      final settingsMap =
          await NotificationService.getNotificationSettingsForUI();
      state = NotificationSettings.fromMap(settingsMap);
    } catch (e) {
      // If loading fails, keep default settings
      print('Failed to load notification settings: $e');
    }
  }

  /// Toggle start of day notification
  Future<void> toggleStartOfDayNotification(bool enabled) async {
    try {
      await NotificationService.updateStartOfDayNotification(enabled);
      state = state.copyWith(
        startOfDayEnabled: enabled,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Failed to update start of day notification: $e');
    }
  }

  /// Toggle end of day notification
  Future<void> toggleEndOfDayNotification(bool enabled) async {
    try {
      await NotificationService.updateEndOfDayNotification(enabled);
      state = state.copyWith(
        endOfDayEnabled: enabled,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Failed to update end of day notification: $e');
    }
  }

  /// Update wake up time
  Future<void> updateWakeUpTime(int hour, int minute) async {
    try {
      await NotificationService.updateWakeUpTime(hour, minute);
      state = state.copyWith(
        wakeUpHour: hour,
        wakeUpMinute: minute,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Failed to update wake up time: $e');
    }
  }

  /// Update sleep time
  Future<void> updateSleepTime(int hour, int minute) async {
    try {
      await NotificationService.updateSleepTime(hour, minute);
      state = state.copyWith(
        sleepHour: hour,
        sleepMinute: minute,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Failed to update sleep time: $e');
    }
  }

  /// Refresh settings from storage
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  /// Check if any daily notifications are enabled
  bool get hasAnyDailyNotificationsEnabled {
    return state.startOfDayEnabled || state.endOfDayEnabled;
  }

  /// Get summary of notification settings for UI display
  String get settingsSummary {
    final List<String> enabled = [];
    if (state.startOfDayEnabled) {
      enabled.add('Morning (${state.wakeUpTimeString})');
    }
    if (state.endOfDayEnabled) {
      enabled.add('Evening (${state.sleepTimeString})');
    }

    if (enabled.isEmpty) {
      return 'No daily reminders';
    } else {
      return enabled.join(', ');
    }
  }
}

/// Example usage for future settings page:
/// 
/// class NotificationSettingsPage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final settings = ref.watch(notificationSettingsProvider);
///     final controller = ref.read(notificationSettingsProvider.notifier);
///     
///     return Scaffold(
///       appBar: AppBar(title: Text('Notification Settings')),
///       body: Column(
///         children: [
///           SwitchListTile(
///             title: Text('Morning Reminder'),
///             subtitle: Text('${settings.wakeUpTimeString}'),
///             value: settings.startOfDayEnabled,
///             onChanged: controller.toggleStartOfDayNotification,
///           ),
///           SwitchListTile(
///             title: Text('Evening Reminder'), 
///             subtitle: Text('${settings.sleepTimeString}'),
///             value: settings.endOfDayEnabled,
///             onChanged: controller.toggleEndOfDayNotification,
///           ),
///           // Time picker widgets for updating times...
///         ],
///       ),
///     );
///   }
/// }
