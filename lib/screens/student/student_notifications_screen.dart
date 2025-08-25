import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/status_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/notification_model.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All Type';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All Prior';

  @override
  void initState() {
    super.initState();
    // Load notifications data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        dataProvider.listenToUserNotifications(
          authProvider.currentUser!.uid,
          role: 'student',
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Status Bar
                const StatusBar(
                  title: "Student Portal",
                  showNotificationBell: true,
                  showBattery: false,
                ),
                const SizedBox(height: 16),

                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Back Button and Title Row
                      Row(
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Title
                          const Expanded(
                            child: Text(
                              "Notifications",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Mark All Read Button
                          Consumer<DataProvider>(
                            builder: (context, dataProvider, child) {
                              final unreadCount = dataProvider.notifications
                                  .where((notification) => !notification.isRead)
                                  .length;

                              if (unreadCount == 0)
                                return const SizedBox.shrink();

                              return GestureDetector(
                                onTap: () => _markAllAsRead(dataProvider),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "Mark All",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Badge Row (separate from title to prevent overflow)
                      const SizedBox(height: 12),
                      Consumer<DataProvider>(
                        builder: (context, dataProvider, child) {
                          final urgentCount = dataProvider.notifications
                              .where(
                                (notification) =>
                                    notification.metadata?['priority'] ==
                                        'urgent' ||
                                    notification.type == 'announcement',
                              )
                              .length;

                          if (urgentCount == 0) return const SizedBox.shrink();

                          return Row(
                            children: [
                              const SizedBox(width: 56), // Align with title
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "$urgentCount Urgent",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Summary
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    final unreadCount = dataProvider.notifications
                        .where((notification) => !notification.isRead)
                        .length;
                    final totalCount = dataProvider.notifications.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        "$unreadCount unread • $totalCount total",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search notifications...",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildResponsiveFilters(),
                ),

                const SizedBox(height: 16),

                // Notification Categories
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    final notifications = dataProvider.notifications;
                    final assignmentCount = notifications
                        .where((n) => n.type == 'assignment')
                        .length;
                    final gradesCount = notifications
                        .where((n) => n.type == 'grades')
                        .length;
                    final updateCount = notifications
                        .where((n) => n.type == 'update')
                        .length;
                    final reminderCount = notifications
                        .where((n) => n.type == 'reminder')
                        .length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            // Stack vertically on narrow screens
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCategoryButton(
                                        '$assignmentCount Assignments',
                                        Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildCategoryButton(
                                        '$gradesCount Grades',
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCategoryButton(
                                        '$updateCount Updates',
                                        Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildCategoryButton(
                                        '$reminderCount Reminders',
                                        Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          // Side by side on wider screens
                          return Row(
                            children: [
                              Expanded(
                                child: _buildCategoryButton(
                                  '$assignmentCount Assignments',
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCategoryButton(
                                  '$gradesCount Grades',
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCategoryButton(
                                  '$updateCount Updates',
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCategoryButton(
                                  '$reminderCount Reminders',
                                  Colors.purple,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Notifications List
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    if (dataProvider.isLoadingNotifications) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final allNotifications = dataProvider.notifications;
                    if (allNotifications.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No notifications found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    // Apply search and filters
                    final searchQuery = _searchController.text.toLowerCase();
                    final filteredNotifications = allNotifications.where((
                      notification,
                    ) {
                      final matchesSearch =
                          notification.title.toLowerCase().contains(
                            searchQuery,
                          ) ||
                          notification.message.toLowerCase().contains(
                            searchQuery,
                          );

                      final matchesType =
                          _selectedType == 'All Type' ||
                          notification.type == _selectedType.toLowerCase();

                      final matchesPriority =
                          _selectedPriority == 'All' ||
                          notification.metadata?['priority'] ==
                              _selectedPriority.toLowerCase();

                      final matchesStatus =
                          _selectedStatus == 'All Prior' ||
                          (_selectedStatus == 'Unread' &&
                              !notification.isRead) ||
                          (_selectedStatus == 'Read' && notification.isRead);

                      return matchesSearch &&
                          matchesType &&
                          matchesPriority &&
                          matchesStatus;
                    }).toList();

                    if (filteredNotifications.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No notifications match your filters',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: filteredNotifications.map((notification) {
                          return _buildNotificationCard(notification);
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1E1C2A),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        underline: Container(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
        isExpanded: true,
        isDense: true,
        alignment: Alignment.centerLeft,
        selectedItemBuilder: (BuildContext context) {
          return items.map((String item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            );
          }).toList();
        },
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResponsiveFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            children: [
              _buildFilterDropdown(
                value: _selectedType,
                items: [
                  'All Type',
                  'Assignment',
                  'Grades',
                  'Update',
                  'Reminder',
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
                label: 'Type',
              ),
              const SizedBox(height: 10),
              _buildFilterDropdown(
                value: _selectedPriority,
                items: ['All', 'Urgent', 'High', 'Medium', 'Normal'],
                onChanged: (value) =>
                    setState(() => _selectedPriority = value!),
                label: 'Priority',
              ),
              const SizedBox(height: 10),
              _buildFilterDropdown(
                value: _selectedStatus,
                items: ['All Prior', 'Unread', 'Read'],
                onChanged: (value) => setState(() => _selectedStatus = value!),
                label: 'Status',
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedType,
                items: [
                  'All Type',
                  'Assignment',
                  'Grades',
                  'Update',
                  'Reminder',
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
                label: 'Type',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedPriority,
                items: ['All', 'Urgent', 'High', 'Medium', 'Normal'],
                onChanged: (value) =>
                    setState(() => _selectedPriority = value!),
                label: 'Priority',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedStatus,
                items: ['All Prior', 'Unread', 'Read'],
                onChanged: (value) => setState(() => _selectedStatus = value!),
                label: 'Status',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isUrgent = notification.priority == 'urgent';
    final isHigh = notification.priority == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? Colors.red.withOpacity(0.3)
              : isHigh
              ? Colors.orange.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getPriorityIcon(notification.priority),
                    color: isUrgent
                        ? Colors.red
                        : isHigh
                        ? Colors.orange
                        : Colors.blue,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),

              const SizedBox(width: 8),

              // Info and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 18),
                  if (!notification.isRead) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            notification.message,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(notification.type, _getTagColor(notification.type)),
              _buildTag(
                notification.priority,
                _getTagColor(notification.priority),
              ),
              if (notification.subject != null)
                _buildTag(notification.subject!, Colors.purple),
            ],
          ),

          const SizedBox(height: 16),

          // Footer Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time
              Text(
                "${_formatDate(notification.createdAt)} • ${_formatTime(notification.createdAt)}",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 8),

              // Sender
              Row(
                children: [
                  Icon(Icons.person, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      notification.senderName ?? 'System',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _markAsRead(notification),
                    child: Icon(Icons.check, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _dismissNotification(notification),
                    child: Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'reminder':
        return Icons.access_time;
      case 'announcement':
        return Icons.notifications;
      case 'assignment':
        return Icons.assignment;
      case 'grades':
        return Icons.grade;
      case 'update':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.celebration;
      case 'medium':
        return Icons.schedule;
      case 'normal':
        return Icons.info;
      default:
        return Icons.info;
    }
  }

  Color _getTagColor(String type) {
    switch (type.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'normal':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'announcement':
        return Colors.purple;
      case 'assignment':
        return Colors.blue;
      case 'grades':
        return Colors.green;
      case 'update':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _markAsRead(NotificationModel notification) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.markNotificationAsRead(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked "${notification.title}" as read'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _dismissNotification(NotificationModel notification) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.deleteNotification(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dismissed "${notification.title}"'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead(DataProvider dataProvider) {
    final unreadNotifications = dataProvider.notifications
        .where((notification) => !notification.isRead)
        .toList();

    for (var notification in unreadNotifications) {
      dataProvider.markNotificationAsRead(notification.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
