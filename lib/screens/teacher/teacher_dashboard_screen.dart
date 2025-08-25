import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/class_model.dart';
import '../../models/event_model.dart';
import '../../models/notification_model.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load teacher data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        dataProvider.loadTeacherData(authProvider.currentUser!.uid);
        dataProvider.listenToTeacherClasses(authProvider.currentUser!.uid);
        dataProvider.listenToEvents();
        dataProvider.listenToUserNotifications(
          authProvider.currentUser!.uid,
          role: 'teacher',
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Dashboard Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(),

                      const SizedBox(height: 24),

                      // Quick Stats
                      _buildQuickStats(),

                      const SizedBox(height: 24),

                      // Today's Schedule
                      _buildTodaySchedule(),

                      const SizedBox(height: 24),

                      // Recent Notifications
                      _buildRecentNotifications(),

                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(),

                      const SizedBox(height: 24),

                      // Recent Events
                      _buildRecentEvents(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final unreadCount = dataProvider.notifications
                  .where((notification) => !notification.isRead)
                  .length;

              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/teacher/notifications');
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final teacher = dataProvider.currentTeacher;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(teacher?.name ?? 'Teacher'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher?.name ?? 'Teacher',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher?.department ?? 'Department',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final classes = dataProvider.teacherClasses;
        final events = dataProvider.events;
        final notifications = dataProvider.notifications;
        final teacher = dataProvider.currentTeacher;

        // Calculate stats
        final totalStudents = classes.fold<int>(
          0,
          (sum, cls) => sum + cls.studentIds.length,
        );
        final totalClasses = classes.length;
        final recentEvents = events
            .where(
              (e) =>
                  e.createdBy == teacher?.uid &&
                  e.createdAt.isAfter(
                    DateTime.now().subtract(const Duration(days: 7)),
                  ),
            )
            .length;
        final unreadNotifications = notifications
            .where((n) => !n.isRead)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Classes',
                    totalClasses.toString(),
                    Icons.class_,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Students',
                    totalStudents.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Recent Events',
                    recentEvents.toString(),
                    Icons.event,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Notifications',
                    unreadNotifications.toString(),
                    Icons.notifications,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final classes = dataProvider.teacherClasses;
        final today = DateTime.now().weekday;

        // Filter classes for today
        final todayClasses = classes
            .where((cls) => cls.schedule.any((slot) => slot.dayOfWeek == today))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (todayClasses.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.schedule, color: Colors.white70, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'No classes scheduled for today',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enjoy your free time!',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayClasses.map((cls) {
                final todaySlot = cls.schedule.firstWhere(
                  (slot) => slot.dayOfWeek == today,
                  orElse: () => cls.schedule.first,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cls.subjectName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${todaySlot.startTime} - ${todaySlot.endTime}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Class: ${cls.classCode} • Students: ${cls.studentIds.length}',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _viewClassDetails(cls),
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildRecentNotifications() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final notifications = dataProvider.notifications.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Recent Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/teacher/notifications');
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.white70,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...notifications
                  .map((notification) => _buildNotificationCard(notification))
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.white.withOpacity(0.1)
              : Colors.blue.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getNotificationTypeColor(
                notification.type,
              ).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getNotificationTypeIcon(notification.type),
              color: _getNotificationTypeColor(notification.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white60, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Take Attendance',
                Icons.check_circle,
                Colors.green,
                () => _navigateToAttendance(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Upload Marks',
                Icons.grade,
                Colors.orange,
                () => _navigateToMarks(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Add Event',
                Icons.event,
                Colors.blue,
                () => _navigateToAddEvent(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Resources',
                Icons.upload_file,
                Colors.purple,
                () => _navigateToResources(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEvents() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final events = dataProvider.events
            .where((e) => e.createdBy == dataProvider.currentTeacher?.uid)
            .take(3)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Recent Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/teacher/home');
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (events.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.event, color: Colors.white70, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'No recent events',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first event',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...events.map((event) => _buildEventCard(event)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getEventTypeColor(event.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEventTypeIcon(event.type),
              color: _getEventTypeColor(event.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  event.type[0].toUpperCase() + event.type.substring(1),
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(event.createdAt),
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _viewEvent(event),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _viewClassDetails(ClassModel classModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          classModel.subjectName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Class Code: ${classModel.classCode}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Students: ${classModel.studentIds.length}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Schedule:',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...classModel.schedule
                  .map(
                    (slot) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        '${slot.dayOfWeek == 1
                            ? 'Mon'
                            : slot.dayOfWeek == 2
                            ? 'Tue'
                            : slot.dayOfWeek == 3
                            ? 'Wed'
                            : slot.dayOfWeek == 4
                            ? 'Thu'
                            : slot.dayOfWeek == 5
                            ? 'Fri'
                            : slot.dayOfWeek == 6
                            ? 'Sat'
                            : 'Sun'}: ${slot.startTime} - ${slot.endTime}',
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ),
                  )
                  .toList(),
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
    );
  }

  void _viewEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(event.title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.description,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.category, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Type: ${event.type}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${_formatDate(event.createdAt)}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              if (event.targetClass != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.class_, color: Colors.white60, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Target: ${event.targetClass}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ],
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
    );
  }

  void _navigateToAttendance() {
    Navigator.pushNamed(context, '/teacher/attendance');
  }

  void _navigateToMarks() {
    Navigator.pushNamed(context, '/teacher/upload-marks');
  }

  void _navigateToAddEvent() {
    Navigator.pushNamed(context, '/teacher/add-event');
  }

  void _navigateToResources() {
    Navigator.pushNamed(context, '/teacher/upload-pdf');
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'exam':
        return Colors.red;
      case 'assignment':
        return Colors.orange;
      case 'event':
        return Colors.green;
      case 'announcement':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type) {
      case 'exam':
        return Icons.quiz;
      case 'assignment':
        return Icons.assignment;
      case 'event':
        return Icons.event;
      case 'announcement':
        return Icons.announcement;
      default:
        return Icons.event;
    }
  }

  Color _getNotificationTypeColor(String type) {
    switch (type) {
      case 'urgent':
        return Colors.red;
      case 'important':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'reminder':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.priority_high;
      case 'important':
        return Icons.info;
      case 'info':
        return Icons.info_outline;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'T';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! Ready to inspire your students today?';
    } else if (hour < 17) {
      return 'Good afternoon! How can we make learning exciting today?';
    } else {
      return 'Good evening! Time to plan tomorrow\'s lessons?';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
