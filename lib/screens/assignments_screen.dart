import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/assignment.dart';

class AssignmentsScreen extends StatefulWidget {
  final List<Assignment> assignments;
  final Function(List<Assignment>) onAssignmentsChanged;

  const AssignmentsScreen({
    super.key,
    required this.assignments,
    required this.onAssignmentsChanged,
  });

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late List<Assignment> _assignments;

  @override
  void initState() {
    super.initState();
    _assignments = List.from(widget.assignments);
  }

  @override
  void didUpdateWidget(covariant AssignmentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assignments != oldWidget.assignments) {
      _assignments = List.from(widget.assignments);
    }
  }

  void _notifyParent() {
    widget.onAssignmentsChanged(List.from(_assignments));
  }

  List<Assignment> _getSortedAssignments() {
    final sorted = List<Assignment>.from(_assignments);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  void _showCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    Priority selectedPriority = Priority.medium;

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
                      isCompleted: false,
                    ),
                  );
                });
                _notifyParent();
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

  void _showEditAssignmentDialog(Assignment assignment) {
    final titleController = TextEditingController(text: assignment.title);
    final courseController = TextEditingController(text: assignment.courseName);
    DateTime selectedDate = assignment.dueDate;
    Priority selectedPriority = assignment.priority;

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
                      isCompleted: assignment.isCompleted,
                    );
                  }
                });
                _notifyParent();
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
          isCompleted: !assignment.isCompleted,
        );
      }
    });
    _notifyParent();
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
              _notifyParent();
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
        title: const Text(
          'Assignments',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildAssignmentList(),
      // Floating action button to create new assignment
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAssignmentDialog,
        backgroundColor: AppColors.yellow,
        child: const Icon(Icons.add, color: AppColors.navyDark),
      ),
    );
  }

  Widget _buildAssignmentList() {
    final assignments = _getSortedAssignments();

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
            const Text(
              'No assignments yet',
              style: TextStyle(color: AppColors.mutedWhite, fontSize: 16),
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

  Widget _buildAssignmentCard(Assignment assignment) {
    final dueText =
        '${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}';

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
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: $dueText',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
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
          // Priority badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const SizedBox(width: 48), // Align with title
                _buildPriorityBadge(assignment.priority),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        color: badgeColor.withAlpha(51),
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
}
