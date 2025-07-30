import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/theme_controller.dart';
import 'package:streakly/pages/main_wrapper.dart';
import 'package:streakly/pages/onboarding/page.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/theme/app_theme.dart';
// import 'package:streakly/utils/habit_data_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await HabitDataMigration.migrateIfNeeded();

  // Initialize notification services
  await NotificationService.initialize();
  await NotificationManager.initialize();
  await NotificationManager.setupIsolateListener();

  runApp(
    DevicePreview(
      enabled: true, // Only enable in debug mode
      builder: (context) => ProviderScope(child: MainApp()),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Streakly - Habit Tracker',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routes: {'/home': (context) => const MainWrapper()},
      home: const OnBoardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
