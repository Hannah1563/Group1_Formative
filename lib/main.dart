import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/assignments_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/schedule_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALU Academic Assistant',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.navy,
        fontFamily: 'Roboto',
      ),
      home: const AssignmentsScreen(),
      routes: {
        '/assignments': (context) => const AssignmentsScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/schedule': (context) => const ScheduleScreen(),
      },
    );
  }
}
