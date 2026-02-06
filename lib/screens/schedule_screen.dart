import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/session.dart';

class ScheduleScreen extends StatelessWidget {
  final List<Session> sessions;
  final Function(List<Session>) onSessionsChanged;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onSessionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Schedule — coming soon',
          style: TextStyle(color: AppColors.mutedWhite, fontSize: 16),
        ),
      ),
    );
  }
}
