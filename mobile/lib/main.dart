import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (wrapped in try-catch due to mock options)
  try {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
  } catch(e) {
     debugPrint("Firebase init failed: $e");
  }

  // Initialize Hive Offline Storage
  await Hive.initFlutter();
  await Hive.openBox('surveys');
  await Hive.openBox('responses_sync');

  runApp(const CommunityBridgeApp());
}

class CommunityBridgeApp extends StatelessWidget {
  const CommunityBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommunityBridge Volunteer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
