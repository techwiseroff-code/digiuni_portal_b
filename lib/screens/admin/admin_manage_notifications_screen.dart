import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class AdminManageNotificationsScreen extends StatefulWidget {
  const AdminManageNotificationsScreen({super.key});

  @override
  State<AdminManageNotificationsScreen> createState() =>
      _AdminManageNotificationsScreenState();
}

class _AdminManageNotificationsScreenState
    extends State<AdminManageNotificationsScreen> {
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
}
