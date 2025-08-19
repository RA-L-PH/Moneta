import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'theme/app_theme.dart';
import 'services/sms_capture.dart';
import 'services/notification_service.dart';
import 'theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'local/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local storage (Hive) for on-device SMS-derived transactions
  await LocalStorage.init();
  // Initialize notification service
  await NotificationService.initialize();
  // Request notification permissions
  await NotificationService.requestPermissions();
  // Best-effort start SMS capture on Android devices
  SmsCaptureService.start();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return MaterialApp(
      title: 'Moneta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode,
      home: const HomeScreen(),
    );
  }
}
