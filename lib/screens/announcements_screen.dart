import 'package:flutter/material.dart';

/// AnnouncementsScreen - Displays and manages academic announcements
/// Features: View, Create, Edit, Delete announcements
/// Categories: All, Academic, Administrative, Events
/// 
/// This screen helps ALU students stay informed about important
/// university updates, deadlines, and events.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List to store all announcements - maintains state during session
  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Reminder: Project Deadlines',
      source: 'Department of Software Engineering',
      description:
          'Committing all deliverables beyond the specified deadline will issue in grade penalties. Please ensure timely submissions.',
      category: AnnouncementCategory.academic,
      datePosted: DateTime(2026, 2, 5),
      isPinned: true,
    ),
    Announcement(
      id: '2',
      title: 'Upcoming Industry Talk',
      source: 'Career Services',
      description:
          'Forming around the Y of 1/4 state your coursework. Join us for an exciting industry talk with leading tech professionals.',
      category: AnnouncementCategory.events,
      datePosted: DateTime(2026, 2, 4),
      isPinned: false,
    ),
    Announcement(
      id: '3',
      title: 'Update for All Students',
      source: 'Academic Affairs',
      description:
          'See additional online courses for asset in your coursework. New learning resources are now available in the E-Learning portal.',
      category: AnnouncementCategory.academic,
      datePosted: DateTime(2026, 2, 3),
      isPinned: false,
    ),
    Announcement(
      id: '4',
      title: 'Library Hours Extended',
      source: 'Student Services',
      description:
          'The library will now be open until 11 PM on weekdays to support your exam preparation. Make the most of this extended access.',
      category: AnnouncementCategory.administrative,
      datePosted: DateTime(2026, 2, 2),
      isPinned: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Filters announcements by category for tab display
  List<Announcement> _getFilteredAnnouncements(AnnouncementCategory? category) {
    List<Announcement> filtered = category == null
        ? _announcements
        : _announcements.where((a) => a.category == category).toList();
    // Sort by pinned first, then by date (newest first)
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.datePosted.compareTo(a.datePosted);
    });
    return filtered;
  }

  /// Shows dialog to create a new announcement
  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final sourceController = TextEditingController();
    final descriptionController = TextEditingController();
    AnnouncementCategory selectedCategory = AnnouncementCategory.academic;
    bool isPinned = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create New Announcement',
            style: TextStyle(
              color: Color(0xFF0B1B3E),
              fontWeight: FontWeight.w600,
              fontSize: 20,
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
                    labelText: 'Announcement Title *',
                    hintText: 'Enter title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Source/Department field
                TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    labelText: 'Source/Department *',
                    hintText: 'e.g., Academic Affairs',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description field
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Enter announcement details',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<AnnouncementCategory>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                  items: AnnouncementCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryDisplayName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Pin toggle
                SwitchListTile(
                  title: const Text('Pin Announcement'),
                  subtitle: const Text('Pinned announcements appear at the top'),
                  value: isPinned,
                  activeTrackColor: const Color(0xFFF2C94C),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setDialogState(() => isPinned = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate required fields
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an announcement title'),
                      backgroundColor: Color(0xFFEB5757),
                    ),
                  );
                  return;
                }
                if (sourceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a source/department'),
                      backgroundColor: Color(0xFFEB5757),
                    ),
                  );
                  return;
                }
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a description'),
                      backgroundColor: Color(0xFFEB5757),
                    ),
                  );
                  return;
                }

                // Create new announcement
                setState(() {
                  _announcements.add(
                    Announcement(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      source: sourceController.text.trim(),
                      description: descriptionController.text.trim(),
                      category: selectedCategory,
                      datePosted: DateTime.now(),
                      isPinned: isPinned,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Announcement created successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2C94C),
                foregroundColor: const Color(0xFF0B1B3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows dialog to edit an existing announcement
  void _showEditAnnouncementDialog(Announcement announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final sourceController = TextEditingController(text: announcement.source);
    final descriptionController =
        TextEditingController(text: announcement.description);
    AnnouncementCategory selectedCategory = announcement.category;
    bool isPinned = announcement.isPinned;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Announcement',
            style: TextStyle(
              color: Color(0xFF0B1B3E),
              fontWeight: FontWeight.w600,
              fontSize: 20,
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
                    labelText: 'Announcement Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    labelText: 'Source/Department *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AnnouncementCategory>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                  items: AnnouncementCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryDisplayName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Pin Announcement'),
                  subtitle: const Text('Pinned announcements appear at the top'),
                  value: isPinned,
                  activeTrackColor: const Color(0xFFF2C94C),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setDialogState(() => isPinned = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate required fields
                if (titleController.text.trim().isEmpty ||
                    sourceController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Color(0xFFEB5757),
                    ),
                  );
                  return;
                }

                // Update announcement
                setState(() {
                  final index =
                      _announcements.indexWhere((a) => a.id == announcement.id);
                  if (index != -1) {
                    _announcements[index] = Announcement(
                      id: announcement.id,
                      title: titleController.text.trim(),
                      source: sourceController.text.trim(),
                      description: descriptionController.text.trim(),
                      category: selectedCategory,
                      datePosted: announcement.datePosted,
                      isPinned: isPinned,
                    );
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Announcement updated successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2C94C),
                foregroundColor: const Color(0xFF0B1B3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows announcement details in a bottom sheet
  void _showAnnouncementDetails(Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category badge and pin indicator
                Row(
                  children: [
                    _buildCategoryBadge(announcement.category),
                    const SizedBox(width: 8),
                    if (announcement.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2C94C).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFF2C94C)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin,
                              size: 14,
                              color: Color(0xFFD4A700),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PINNED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD4A700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1B3E),
                  ),
                ),
                const SizedBox(height: 8),

                // Source
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement.source,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(announcement.datePosted),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Divider
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 16),

                // Description
                Text(
                  announcement.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditAnnouncementDialog(announcement);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B1B3E),
                          side: const BorderSide(color: Color(0xFF0B1B3E)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteAnnouncement(announcement);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEB5757),
                          side: const BorderSide(color: Color(0xFFEB5757)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Deletes an announcement with confirmation
  void _deleteAnnouncement(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Announcement',
          style: TextStyle(
            color: Color(0xFF0B1B3E),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${announcement.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _announcements.removeWhere((a) => a.id == announcement.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Announcement deleted'),
                  backgroundColor: Color(0xFFEB5757),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEB5757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Toggles pin status of an announcement
  void _togglePinStatus(Announcement announcement) {
    setState(() {
      final index = _announcements.indexWhere((a) => a.id == announcement.id);
      if (index != -1) {
        _announcements[index] = Announcement(
          id: announcement.id,
          title: announcement.title,
          source: announcement.source,
          description: announcement.description,
          category: announcement.category,
          datePosted: announcement.datePosted,
          isPinned: !announcement.isPinned,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          announcement.isPinned
              ? 'Announcement unpinned'
              : 'Announcement pinned to top',
        ),
        backgroundColor: const Color(0xFF0B1B3E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Returns display name for category
  String _getCategoryDisplayName(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.academic:
        return 'Academic';
      case AnnouncementCategory.administrative:
        return 'Administrative';
      case AnnouncementCategory.events:
        return 'Events';
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Returns relative time string
  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1B3E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1B3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF2C94C),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFD8DCE6),
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Academic'),
            Tab(text: 'Administrative'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementList(null),
          _buildAnnouncementList(AnnouncementCategory.academic),
          _buildAnnouncementList(AnnouncementCategory.administrative),
          _buildAnnouncementList(AnnouncementCategory.events),
        ],
      ),
      // Floating action button to create new announcement
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAnnouncementDialog,
        backgroundColor: const Color(0xFFF2C94C),
        child: const Icon(Icons.add, color: Color(0xFF0B1B3E)),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Shows search dialog
  void _showSearchDialog() {
    final searchController = TextEditingController();
    List<Announcement> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Search Announcements',
            style: TextStyle(
              color: Color(0xFF0B1B3E),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by title or description...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B1B3E),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (query) {
                    setDialogState(() {
                      if (query.isEmpty) {
                        searchResults = [];
                      } else {
                        searchResults = _announcements
                            .where((a) =>
                                a.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                a.description
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                a.source
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final announcement = searchResults[index];
                        return ListTile(
                          title: Text(
                            announcement.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            announcement.source,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showAnnouncementDetails(announcement);
                          },
                        );
                      },
                    ),
                  )
                else if (searchController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No announcements found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of announcements filtered by category
  Widget _buildAnnouncementList(AnnouncementCategory? category) {
    final announcements = _getFilteredAnnouncements(category);

    if (announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: const Color(0xFFD8DCE6),
            ),
            const SizedBox(height: 16),
            Text(
              category == null
                  ? 'No announcements yet'
                  : 'No ${_getCategoryDisplayName(category).toLowerCase()} announcements',
              style: const TextStyle(
                color: Color(0xFFD8DCE6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to create one',
              style: TextStyle(
                color: Color(0xFFD8DCE6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        return _buildAnnouncementCard(announcements[index]);
      },
    );
  }

  /// Builds individual announcement card
  Widget _buildAnnouncementCard(Announcement announcement) {
    return GestureDetector(
      onTap: () => _showAnnouncementDetails(announcement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and pin
            if (announcement.isPinned)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2C94C),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: 14,
                      color: Color(0xFF0B1B3E),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Pinned',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1B3E),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B1B3E),
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF0B1B3E),
                          size: 20,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditAnnouncementDialog(announcement);
                          } else if (value == 'delete') {
                            _deleteAnnouncement(announcement);
                          } else if (value == 'pin') {
                            _togglePinStatus(announcement);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  announcement.isPinned
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin,
                                  size: 20,
                                  color: const Color(0xFF0B1B3E),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  announcement.isPinned ? 'Unpin' : 'Pin to top',
                                ),
                              ],
                            ),
                          ),
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
                                Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Color(0xFFEB5757),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Color(0xFFEB5757)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Source
                  Text(
                    announcement.source,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description (truncated)
                  Text(
                    announcement.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer with category badge and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryBadge(announcement.category),
                      Text(
                        _getRelativeTime(announcement.datePosted),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds category badge
  Widget _buildCategoryBadge(AnnouncementCategory category) {
    Color badgeColor;
    switch (category) {
      case AnnouncementCategory.academic:
        badgeColor = const Color(0xFF0B1B3E);
        break;
      case AnnouncementCategory.administrative:
        badgeColor = const Color(0xFF6B7280);
        break;
      case AnnouncementCategory.events:
        badgeColor = const Color(0xFF4CAF50);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        _getCategoryDisplayName(category).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  /// Builds bottom navigation bar with consistent styling
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 3, // Announcements tab is active
      backgroundColor: const Color(0xFF07152F),
      selectedItemColor: const Color(0xFFF2C94C),
      unselectedItemColor: const Color(0xFFD8DCE6),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          // Navigate to Dashboard/Risk Status
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/risk-status',
            (route) => false,
          );
        } else if (index == 1) {
          // Navigate to Assignments
          Navigator.pushNamed(context, '/assignments');
        } else if (index == 2) {
          // Navigate to Schedule (if implemented)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule feature coming soon!'),
              backgroundColor: Color(0xFF0B1B3E),
            ),
          );
        }
        // index 3 is current screen (Announcements)
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
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign),
          label: 'Announce',
        ),
      ],
    );
  }
}

/// Announcement categories to organize content
enum AnnouncementCategory { academic, administrative, events }

/// Announcement model class representing a single announcement
class Announcement {
  final String id;
  final String title;
  final String source;
  final String description;
  final AnnouncementCategory category;
  final DateTime datePosted;
  final bool isPinned;

  Announcement({
    required this.id,
    required this.title,
    required this.source,
    required this.description,
    required this.category,
    required this.datePosted,
    required this.isPinned,
  });
}
