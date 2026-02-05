import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// AssignmentsScreen - Manages student assignments with full CRUD functionality
/// Features: Create, View, Edit, Delete, Mark Complete assignments
/// Tabs: All, Formative, Summative to filter assignment types
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List to store all assignments - maintains state during session
  final List<Assignment> _assignments = [
    Assignment(
      id: '1',
      title: 'Mobile Dev Formative 1',
      dueDate: DateTime(2026, 2, 18),
      courseName: 'Mobile Development',
      priority: Priority.high,
      type: AssignmentType.formative,
      isCompleted: false,
    ),
    Assignment(
      id: '2',
      title: 'Data Structures Quiz',
      dueDate: DateTime(2026, 2, 10),
      courseName: 'Data Structures',
      priority: Priority.medium,
      type: AssignmentType.formative,
      isCompleted: false,
    ),
    Assignment(
      id: '3',
      title: 'Final Project Submission',
      dueDate: DateTime(2026, 3, 1),
      courseName: 'Mobile Development',
      priority: Priority.high,
      type: AssignmentType.summative,
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Filters assignments by type for tab display
  List<Assignment> _getFilteredAssignments(AssignmentType? type) {
    List<Assignment> filtered = type == null
        ? _assignments
        : _assignments.where((a) => a.type == type).toList();
    // Sort by due date (earliest first)
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filtered;
  }

  /// Shows dialog to create a new assignment
  void _showCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    Priority selectedPriority = Priority.medium;
    AssignmentType selectedType = AssignmentType.formative;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Create New Assignment',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field (required)
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Assignment Title *',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.navy),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Course name field
                TextField(
                  controller: courseController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.navy),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Due date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Priority dropdown
                DropdownButtonFormField<Priority>(
                  initialValue: selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority Level',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: Priority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Assignment type dropdown
                DropdownButtonFormField<AssignmentType>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Assignment Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: AssignmentType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an assignment title'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }
                // Create new assignment
                setState(() {
                  _assignments.add(
                    Assignment(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      dueDate: selectedDate,
                      courseName: courseController.text.trim().isEmpty
                          ? 'General'
                          : courseController.text.trim(),
                      priority: selectedPriority,
                      type: selectedType,
                      isCompleted: false,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment created successfully!'),
                    backgroundColor: AppColors.statusGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.navyDark,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows dialog to edit an existing assignment
  void _showEditAssignmentDialog(Assignment assignment) {
    final titleController = TextEditingController(text: assignment.title);
    final courseController = TextEditingController(text: assignment.courseName);
    DateTime selectedDate = assignment.dueDate;
    Priority selectedPriority = assignment.priority;
    AssignmentType selectedType = assignment.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Edit Assignment',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Assignment Title *',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: courseController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  initialValue: selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority Level',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: Priority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AssignmentType>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Assignment Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: AssignmentType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an assignment title'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }
                // Update assignment
                setState(() {
                  final index = _assignments.indexWhere(
                    (a) => a.id == assignment.id,
                  );
                  if (index != -1) {
                    _assignments[index] = Assignment(
                      id: assignment.id,
                      title: titleController.text.trim(),
                      dueDate: selectedDate,
                      courseName: courseController.text.trim().isEmpty
                          ? 'General'
                          : courseController.text.trim(),
                      priority: selectedPriority,
                      type: selectedType,
                      isCompleted: assignment.isCompleted,
                    );
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment updated successfully!'),
                    backgroundColor: AppColors.statusGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.navyDark,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles assignment completion status
  void _toggleComplete(Assignment assignment) {
    setState(() {
      final index = _assignments.indexWhere((a) => a.id == assignment.id);
      if (index != -1) {
        _assignments[index] = Assignment(
          id: assignment.id,
          title: assignment.title,
          dueDate: assignment.dueDate,
          courseName: assignment.courseName,
          priority: assignment.priority,
          type: assignment.type,
          isCompleted: !assignment.isCompleted,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          assignment.isCompleted
              ? 'Assignment marked as incomplete'
              : 'Assignment marked as complete!',
        ),
        backgroundColor: assignment.isCompleted
            ? AppColors.navy
            : AppColors.statusGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Deletes an assignment with confirmation
  void _deleteAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _assignments.removeWhere((a) => a.id == assignment.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assignment deleted'),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Assignments',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.yellow,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.mutedWhite,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Formative'),
            Tab(text: 'Summative'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignmentList(null),
          _buildAssignmentList(AssignmentType.formative),
          _buildAssignmentList(AssignmentType.summative),
        ],
      ),
      // Floating action button to create new assignment
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAssignmentDialog,
        backgroundColor: AppColors.yellow,
        child: const Icon(Icons.add, color: AppColors.navyDark),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Builds the list of assignments filtered by type
  Widget _buildAssignmentList(AssignmentType? type) {
    final assignments = _getFilteredAssignments(type);

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.mutedWhite,
            ),
            const SizedBox(height: 16),
            Text(
              type == null
                  ? 'No assignments yet'
                  : 'No ${type.name} assignments',
              style: const TextStyle(color: AppColors.mutedWhite, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to create one',
              style: TextStyle(color: AppColors.mutedWhite, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildAssignmentCard(assignments[index]);
      },
    );
  }

  /// Builds individual assignment card with actions
  Widget _buildAssignmentCard(Assignment assignment) {
    final isOverdue =
        assignment.dueDate.isBefore(DateTime.now()) && !assignment.isCompleted;
    final daysUntilDue = assignment.dueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: assignment.isCompleted
            ? Border.all(color: AppColors.statusGreen, width: 2)
            : null,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            leading: // Checkbox to mark complete
            IconButton(
              icon: Icon(
                assignment.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: assignment.isCompleted
                    ? AppColors.statusGreen
                    : AppColors.navy,
                size: 28,
              ),
              onPressed: () => _toggleComplete(assignment),
            ),
            title: Text(
              assignment.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                decoration: assignment.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  assignment.courseName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isOverdue ? AppColors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOverdue
                          ? 'Overdue!'
                          : daysUntilDue == 0
                          ? 'Due today'
                          : daysUntilDue == 1
                          ? 'Due tomorrow'
                          : 'Due in $daysUntilDue days',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOverdue ? AppColors.red : Colors.grey[600],
                        fontWeight: isOverdue
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.navy),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditAssignmentDialog(assignment);
                } else if (value == 'delete') {
                  _deleteAssignment(assignment);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Priority and type badges
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const SizedBox(width: 48), // Align with title
                _buildPriorityBadge(assignment.priority),
                const SizedBox(width: 8),
                _buildTypeBadge(assignment.type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds priority indicator badge
  Widget _buildPriorityBadge(Priority priority) {
    Color badgeColor;
    switch (priority) {
      case Priority.high:
        badgeColor = AppColors.red;
        break;
      case Priority.medium:
        badgeColor = AppColors.yellow;
        break;
      case Priority.low:
        badgeColor = AppColors.statusGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  /// Builds assignment type badge
  Widget _buildTypeBadge(AssignmentType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    );
  }

  /// Builds bottom navigation bar with consistent styling
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 1, // Assignments tab is active
      backgroundColor: AppColors.navyDark,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: AppColors.mutedWhite,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          // Navigate to Dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/risk-status',
            (route) => false,
          );
        }
        // index 1 is current screen (Assignments)
        // index 2 would be Schedule (handled by other team member)
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assignments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
      ],
    );
  }
}

/// Priority levels for assignments
enum Priority { high, medium, low }

/// Assignment types to categorize work
enum AssignmentType { formative, summative }

/// Assignment model class representing a single assignment
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final Priority priority;
  final AssignmentType type;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    required this.priority,
    required this.type,
    required this.isCompleted,
  });
}
