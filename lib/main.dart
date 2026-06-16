import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/sacco_database.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/member_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await SaccoDatabase().database;
  
  // Check if user is already logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? loggedInUserId = prefs.getInt('loggedInUserId');
  String? userRole = prefs.getString('userRole');
  
  runApp(MyApp(
    initialRoute: loggedInUserId != null ? (userRole == 'admin' ? '/admin' : '/member') : '/login',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2NK SACCO - Mobile Banking',
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/member': (context) => const MemberDashboard(),
        '/admin': (context) => const AdminDashboard(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}