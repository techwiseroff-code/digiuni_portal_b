import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/status_bar.dart';
// removed unused: glass_container
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/event_model.dart';
import 'student_profile_screen.dart';
import 'student_id_card_screen.dart';
import 'student_notes_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _index = 0;

  final pages = [
    HomePageContent(),
    StudentProfileScreen(),
    StudentIDCardScreen(),
    StudentNotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgDark,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
        },
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StatusBar(title: "Home"),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildUpcomingEvents(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final studentName = authProvider.userData?.name ?? 'Student';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello $studentName!', style: Styles.titleText),
            const SizedBox(height: 8),
            const Text(
              'Student Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'View Attendance',
                Icons.check_circle,
                Colors.green,
                () {
                  Navigator.pushNamed(context, '/student/attendance');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Check Grades',
                Icons.grade,
                Colors.blue,
                () {
                  Navigator.pushNamed(context, '/student/performance');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'View Timetable',
                Icons.schedule,
                Colors.purple,
                () {
                  Navigator.pushNamed(context, '/student/timetable');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'My Notes',
                Icons.note,
                Colors.orange,
                () {
                  Navigator.pushNamed(context, '/student/notes');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
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

  Widget _buildUpcomingEvents() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final upcomingEvents = dataProvider.events
            .where(
              (event) =>
                  event.targetRole == 'student' || event.targetRole == 'all',
            )
            .take(3)
            .toList();

        if (upcomingEvents.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: Text(
                    'No upcoming events',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...upcomingEvents
                .map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEventCard(event),
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: TextStyle(fontSize: 14, color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${event.date.day}/${event.date.month}/${event.date.year}',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
