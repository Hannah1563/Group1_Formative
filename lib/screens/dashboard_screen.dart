import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/assignment.dart';
import '../models/session.dart';

class DashboardScreen extends StatelessWidget {
  final List<Assignment> assignments;
  final List<Session> sessions;

  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Dashboard — coming soon',
          style: TextStyle(color: AppColors.mutedWhite, fontSize: 16),
        ),
      ),
    );
  }
}
