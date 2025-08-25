import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class AdminManageClassesScreen extends StatefulWidget {
  const AdminManageClassesScreen({super.key});

  @override
  State<AdminManageClassesScreen> createState() =>
      _AdminManageClassesScreenState();
}

class _AdminManageClassesScreenState extends State<AdminManageClassesScreen> {
  final _classCodeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().listenToAllClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Classes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateClassDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dp, _) {
          final classes = dp.teacherClasses; // reused list for all classes
          if (classes.isEmpty) {
            return const Center(child: Text('No classes'));
          }
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final c = classes[index];
              return ListTile(
                title: Text('${c.classCode} • ${c.subjectName}'),
                subtitle: Text(
                  'Teacher: ${c.teacherName} • Students: ${c.studentIds.length}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'delete') {
                      await context.read<DataProvider>().deleteClass(c.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Class deleted')),
                        );
                      }
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

  void _showCreateClassDialog() {
    _classCodeController.clear();
    _subjectController.clear();
    _roomController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _classCodeController,
                decoration: const InputDecoration(labelText: 'Class Code'),
              ),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room'),
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
                await context.read<DataProvider>().createClass({
                  'classCode': _classCodeController.text.trim(),
                  'subjectName': _subjectController.text.trim(),
                  'teacherId': '',
                  'teacherName': '',
                  'studentIds': <String>[],
                  'schedule': <Map<String, dynamic>>[],
                  'room': _roomController.text.trim(),
                  'description': null,
                  'createdAt': DateTime.now(),
                  'isActive': true,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class created')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
