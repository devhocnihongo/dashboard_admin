import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'views/pages/admin_dashboard_page.dart';
import 'views/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;

  void _handleLoginSuccess() {
    setState(() {
      _loggedIn = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _loggedIn
          ? AdminDashboardPage(
        onLogout: _handleLogout,
      )
          : LoginPage(
        onLoginSuccess: _handleLoginSuccess,
      ),
    );
  }
}