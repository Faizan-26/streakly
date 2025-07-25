import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/pages/onboarding/page.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/pages/home_page.dart';
import 'package:streakly/utils/habit_data_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run data migration for existing habits
  await HabitDataMigration.migrateIfNeeded();

  // Initialize notification services
  await NotificationService.initialize();
  await NotificationManager.initialize();
  await NotificationManager.setupIsolateListener();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => ProviderScope(child: MainApp()), // Wrap your app
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streakly - Habit Tracker',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      home: const OnBoardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
