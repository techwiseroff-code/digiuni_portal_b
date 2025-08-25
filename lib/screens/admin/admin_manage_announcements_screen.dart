import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/event_model.dart';

class AdminManageAnnouncementsScreen extends StatefulWidget {
  const AdminManageAnnouncementsScreen({super.key});

  @override
  State<AdminManageAnnouncementsScreen> createState() =>
      _AdminManageAnnouncementsScreenState();
}

class _AdminManageAnnouncementsScreenState
    extends State<AdminManageAnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().listenToAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Announcements')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        child: const Icon(Icons.add),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dp, _) {
          final events = dp.events;
          if (events.isEmpty) {
            return const Center(child: Text('No announcements'));
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.type} • ${e.targetRole ?? 'all'}'),
              );
            },
          );
        },
      ),
    );
  }

  void _createEvent() async {
    final dp = context.read<DataProvider>();
    final id = dp.generateId();
    final auth = context.read<AuthProvider>();
    final ev = EventModel(
      id: id,
      title: 'Announcement',
      description: 'Details',
      type: 'announcement',
      createdBy: auth.currentUser!.uid,
      createdByName: auth.userData?.name ?? 'Admin',
      createdByRole: 'admin',
      createdAt: DateTime.now(),
      date: DateTime.now(),
      isActive: true,
      targetRole: 'all',
      targetClass: null,
      metadata: const {},
    );
    await dp.createEvent(ev);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event created')));
    }
  }
}
