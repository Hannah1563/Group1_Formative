import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/status_metric_card.dart';

class RiskStatusScreen extends StatelessWidget {
  final String userName;
  final double attendancePercentage;
  final double assignmentPercentage;
  final double averageExcitePercentage;

  const RiskStatusScreen({
    super.key,
    this.userName = 'Alex',
    this.attendancePercentage = 75,
    this.assignmentPercentage = 60,
    this.averageExcitePercentage = 63,
  });

  bool get isAtRisk =>
      attendancePercentage < 75 ||
      assignmentPercentage < 75 ||
      averageExcitePercentage < 75;

  Color _getStatusColor(double percentage) {
    if (percentage >= 75) {
      return AppColors.statusGreen;
    } else if (percentage >= 60) {
      return AppColors.statusYellow;
    } else {
      return AppColors.statusRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Risk Status',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Hello $userName  ${isAtRisk ? "At Risk" : "On Track"}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatusMetricCard(
                          percentage: attendancePercentage,
                          label: 'Attendance',
                          backgroundColor: _getStatusColor(attendancePercentage),
                        ),
                        const SizedBox(width: 16),
                        StatusMetricCard(
                          percentage: assignmentPercentage,
                          label: 'Assignment to\nStatement',
                          backgroundColor: _getStatusColor(assignmentPercentage),
                        ),
                        const SizedBox(width: 16),
                        StatusMetricCard(
                          percentage: averageExcitePercentage,
                          label: 'Average\nExcite',
                          backgroundColor: _getStatusColor(averageExcitePercentage),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connecting to support...'),
                          backgroundColor: AppColors.accentYellow,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Help',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
