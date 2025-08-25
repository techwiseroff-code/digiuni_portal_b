import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class AdminManageTimetableScreen extends StatefulWidget {
  const AdminManageTimetableScreen({super.key});

  @override
  State<AdminManageTimetableScreen> createState() =>
      _AdminManageTimetableScreenState();
}

class _AdminManageTimetableScreenState
    extends State<AdminManageTimetableScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().listenToAllTimetables();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Timetables')),
      body: Consumer<DataProvider>(
        builder: (context, dp, _) {
          final tts = dp.timetables;
          if (tts.isEmpty) return const Center(child: Text('No timetables'));
          return ListView.builder(
            itemCount: tts.length,
            itemBuilder: (context, index) {
              final t = tts[index];
              return ListTile(
                title: Text('Class: ${t.className}'),
                subtitle: Text('Slots: ${t.slots.length}'),
              );
            },
          );
        },
      ),
    );
  }
}
