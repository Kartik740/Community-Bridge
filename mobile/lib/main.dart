// lib/main.dart
// App entry point — initialises Firebase, Hive, notifications, and provides
// all providers to the widget tree. Uses SplashScreen as home.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/survey_provider.dart';
import 'providers/response_provider.dart';
import 'providers/task_provider.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[main] Firebase init failed: $e');
  }

  // Hive offline storage
  await HiveService.init();

  // Notifications (FCM + local)
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('[main] Notification init failed: $e');
  }

  // Auto-sync on connectivity restore
  SyncService().initConnectivityListener();

  runApp(const CommunityBridgeApp());
}

class CommunityBridgeApp extends StatelessWidget {
  const CommunityBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => ResponseProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider.value(value: SyncService()),
      ],
      child: MaterialApp(
        title: 'CommunityBridge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
        builder: (context, child) {
          // Slightly scale down text for better readability on larger screens
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
