import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_home_screen.dart';
import 'screens/write_post_screen.dart';
import 'screens/write_omukwan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/password_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '개축',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Pretendard',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/mail': (context) => const MainHomeScreen(),
        '/write': (context) => const WritePostScreen(),
        '/write_omukwan': (context) => const WriteOmukwanScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/password': (context) => const PasswordScreen(phoneNumber: ''),
      },
    );
  }
}
