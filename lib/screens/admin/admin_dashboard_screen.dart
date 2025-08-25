import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, int> _stats = const {
    'students': 0,
    'teachers': 0,
    'admins': 0,
    'classes': 0,
    'events': 0,
    'notifications': 0,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAdmin) {
        final data = Provider.of<DataProvider>(context, listen: false);
        data.listenToUsers();
        data.listenToAllClasses();
        data.listenToAllEvents();
        data.listenToAllNotifications();
        final stats = await data.getSystemStats();
        if (mounted) {
          setState(() {
            _stats = stats;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStat(
                  'Students',
                  _stats['students'] ?? 0,
                  Icons.person_outline,
                ),
                _buildStat(
                  'Teachers',
                  _stats['teachers'] ?? 0,
                  Icons.school_outlined,
                ),
                _buildStat(
                  'Admins',
                  _stats['admins'] ?? 0,
                  Icons.admin_panel_settings_outlined,
                ),
                _buildStat('Classes', _stats['classes'] ?? 0, Icons.class_),
                _buildStat('Events', _stats['events'] ?? 0, Icons.event),
                _buildStat(
                  'Notifications',
                  _stats['notifications'] ?? 0,
                  Icons.notifications,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<DataProvider>(
                builder: (context, dp, _) {
                  return ListView(
                    children: [
                      ListTile(
                        title: const Text('Manage Users'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/users'),
                      ),
                      ListTile(
                        title: const Text('Manage Classes'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/classes'),
                      ),
                      ListTile(
                        title: const Text('Manage Timetable'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/timetable'),
                      ),
                      ListTile(
                        title: const Text('Manage Announcements'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/admin/announcements',
                        ),
                      ),
                      ListTile(
                        title: const Text('Manage Notifications'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/admin/notifications',
                        ),
                      ),
                      ListTile(
                        title: const Text('Reports'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/reports'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
