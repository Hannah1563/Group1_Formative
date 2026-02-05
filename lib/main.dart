import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class _LayoutTuning {
  static const double greetingTop = 12;
  static const double cardsOffsetY = 0;
  static const double buttonOffsetY = 0;
}

class AppColors {
  static const navy = Color(0xFF0B1B3E);
  static const navyDark = Color(0xFF07152F);
  static const yellow = Color(0xFFF2C94C);
  static const red = Color(0xFFEB5757);
  static const white = Colors.white;
  static const mutedWhite = Color(0xFFD8DCE6);
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
    );
  }
}

class RiskStatusScreen extends StatelessWidget {
  const RiskStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = const [
      _StatMetric(value: '75%', label: 'Attendance', color: AppColors.red),
      _StatMetric(
        value: '60%',
        label: 'Assignment to\nSubmit',
        color: AppColors.yellow,
        valueColor: AppColors.navyDark,
      ),
      _StatMetric(value: '63%', label: 'Average\nExcise', color: AppColors.red),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        foregroundColor: AppColors.white,
        leading: const BackButton(),
        title: const Text(
          'Your Risk Status',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      top: _LayoutTuning.greetingTop,
                      left: 0,
                      right: 0,
                      child: const Text(
                        'Hello Alex At Risk',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset(0, _LayoutTuning.cardsOffsetY),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < stats.length; i++) ...[
                                  Expanded(
                                    child: RiskStatCard(metric: stats[i]),
                                  ),
                                  if (i != stats.length - 1)
                                    const SizedBox(width: 12),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Transform.translate(
                            offset: Offset(0, _LayoutTuning.buttonOffsetY),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Get Help',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        backgroundColor: AppColors.navyDark,
        selectedItemColor: AppColors.yellow,
        unselectedItemColor: AppColors.mutedWhite,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Quizlists'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'E-Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }
}

class _StatMetric {
  const _StatMetric({
    required this.value,
    required this.label,
    required this.color,
    this.valueColor = AppColors.white,
  });

  final String value;
  final String label;
  final Color color;
  final Color valueColor;
}

class RiskStatCard extends StatelessWidget {
  const RiskStatCard({super.key, required this.metric});

  final _StatMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 92,
          height: 92,
          child: Container(
            decoration: BoxDecoration(
              color: metric.color,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              metric.value,
              style: TextStyle(
                color: metric.valueColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: Text(
            metric.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: AppColors.mutedWhite,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
