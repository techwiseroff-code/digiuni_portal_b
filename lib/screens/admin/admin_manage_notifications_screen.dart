import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/notification_model.dart';

class AdminManageNotificationsScreen extends StatefulWidget {
  const AdminManageNotificationsScreen({super.key});

  @override
  State<AdminManageNotificationsScreen> createState() =>
      _AdminManageNotificationsScreenState();
}

class _AdminManageNotificationsScreenState
    extends State<AdminManageNotificationsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetRole = 'all';
  String? _targetUserId;
  String? _targetClass;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().listenToAllNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Notifications')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showComposeDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dp, _) {
          final list = dp.notifications;
          if (list.isEmpty)
            return const Center(child: Text('No notifications'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final n = list[index];
              return Dismissible(
                key: ValueKey(n.id),
                background: Container(color: Colors.redAccent),
                onDismissed: (_) async {
                  await context.read<DataProvider>().deleteNotification(n.id);
                },
                child: ListTile(
                  title: Text(n.title),
                  subtitle: Text(n.message),
                  trailing: n.isRead
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showComposeDialog() {
    _titleController.clear();
    _messageController.clear();
    _targetRole = 'all';
    _targetUserId = null;
    _targetClass = null;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
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
                final auth = context.read<AuthProvider>();
                final id = dp.generateId();
                await dp.createNotification(
                  NotificationModel(
                    id: id,
                    title: _titleController.text.trim(),
                    message: _messageController.text.trim(),
                    type: 'general',
                    targetUserId: _targetUserId,
                    targetRole: _targetRole == 'all' ? 'all' : _targetRole,
                    targetClass: _targetClass,
                    senderId: auth.currentUser!.uid,
                    senderName: auth.userData?.name ?? 'Admin',
                    senderRole: 'admin',
                    createdAt: DateTime.now(),
                    isRead: false,
                    actionUrl: null,
                    metadata: const {},
                  ),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification sent')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
