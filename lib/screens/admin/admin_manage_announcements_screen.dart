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
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _targetRole = 'all';
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
        onPressed: _showCreateEventDialog,
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
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'delete') {
                      await context.read<DataProvider>().deleteEvent(e.id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateEventDialog() {
    _titleController.clear();
    _descController.clear();
    _targetRole = 'all';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _targetRole,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'student', child: Text('Students')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
                ],
                onChanged: (v) => setState(() => _targetRole = v ?? 'all'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dp = context.read<DataProvider>();
                final id = dp.generateId();
                final auth = context.read<AuthProvider>();
                final ev = EventModel(
                  id: id,
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  type: 'announcement',
                  createdBy: auth.currentUser!.uid,
                  createdByName: auth.userData?.name ?? 'Admin',
                  createdByRole: 'admin',
                  createdAt: DateTime.now(),
                  date: DateTime.now(),
                  isActive: true,
                  targetRole: _targetRole == 'all' ? 'all' : _targetRole,
                  targetClass: null,
                  metadata: const {},
                );
                await dp.createEvent(ev);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Announcement posted')),
                  );
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
