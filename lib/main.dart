import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // ✅ Corrected import path
import 'screens/landing_page.dart';
import 'screens/register_page.dart';
import 'screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase with correct options based on the platform
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web, // Use Web options
      );
    } else {
      await Firebase.initializeApp(
        options:
            DefaultFirebaseOptions
                .currentPlatform, // Auto-select for Android/iOS
      );
    }
    runApp(MyApp());
  } catch (e) {
    print("🔥 Firebase initialization error: $e");
    // Optional: Show a user-friendly error screen on initialization failure
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Topsy',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LandingPage(),
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
