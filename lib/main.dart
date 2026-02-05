import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/risk_status_screen.dart';
import 'screens/assignments_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Risk Status',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.navy,
        fontFamily: 'Roboto',
      ),
      home: const RiskStatusScreen(),
      routes: {
        '/assignments': (context) => const AssignmentsScreen(),
        '/risk-status': (context) => const RiskStatusScreen(),
      },
    );
  }
}
