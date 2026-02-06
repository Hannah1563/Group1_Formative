import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'models/assignment.dart';
import 'models/session.dart';
import 'screens/assignments_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/schedule_screen.dart';
import 'services/storage_service.dart';
import 'widgets/bottom_nav_bar.dart';

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
      home: const HomeWrapper(),
    );
  }
}

// main wrapper that holds all the app state and switches between tabs
class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0; // which tab we're on
  List<Assignment> _assignments = [];
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load saved data when app starts
  Future<void> _loadData() async {
    final assignments = await StorageService.loadAssignments();
    final sessions = await StorageService.loadSessions();
    setState(() {
      _assignments = assignments;
      _sessions = sessions;
      _isLoading = false;
    });
  }

  void _onAssignmentsChanged(List<Assignment> updatedAssignments) {
    setState(() {
      _assignments = updatedAssignments;
    });
    StorageService.saveAssignments(updatedAssignments);
  }

  void _onSessionsChanged(List<Session> updatedSessions) {
    setState(() {
      _sessions = updatedSessions;
    });
    StorageService.saveSessions(updatedSessions);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.yellow,
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            assignments: _assignments,
            sessions: _sessions,
          ),
          AssignmentsScreen(
            assignments: _assignments,
            onAssignmentsChanged: _onAssignmentsChanged,
          ),
          ScheduleScreen(
            sessions: _sessions,
            onSessionsChanged: _onSessionsChanged,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
