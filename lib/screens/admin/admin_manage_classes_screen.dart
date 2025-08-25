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
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<DataProvider>().deleteClass(c.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class deleted')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
