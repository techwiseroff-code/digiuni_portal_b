import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                    if (v == 'edit') {
                      _showEditClassDialog(
                        classId: c.id,
                        classCode: c.classCode,
                        subjectName: c.subjectName,
                        currentTeacherId: c.teacherId,
                        currentTeacherName: c.teacherName,
                        currentStudentIds: List<String>.from(c.studentIds),
                      );
                    } else if (v == 'delete') {
                      await context.read<DataProvider>().deleteClass(c.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Class deleted')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
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

  void _showEditClassDialog({
    required String classId,
    required String classCode,
    required String subjectName,
    required String currentTeacherId,
    required String currentTeacherName,
    required List<String> currentStudentIds,
  }) {
    String? selectedTeacherId = currentTeacherId.isNotEmpty
        ? currentTeacherId
        : null;
    String? selectedTeacherName = currentTeacherName.isNotEmpty
        ? currentTeacherName
        : null;
    final selectedStudents = currentStudentIds.toSet();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit $classCode • $subjectName'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assign Teacher'),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'teacher')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final items = snapshot.hasData
                            ? snapshot.data!.docs
                            : <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                        return DropdownButton<String>(
                          value: selectedTeacherId,
                          isExpanded: true,
                          hint: const Text('Select Teacher'),
                          items: items
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(
                                    (d.data()['name'] ?? '') as String,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setStateDialog(() {
                              selectedTeacherId = v;
                              if (v != null) {
                                final doc = items.firstWhere((e) => e.id == v);
                                selectedTeacherName =
                                    (doc.data()['name'] ?? '') as String;
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Enroll Students'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 280,
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'student')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final students = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final s = students[index];
                              final name = (s.data()['name'] ?? '') as String;
                              final email = (s.data()['email'] ?? '') as String;
                              final checked = selectedStudents.contains(s.id);
                              return CheckboxListTile(
                                value: checked,
                                onChanged: (v) {
                                  setStateDialog(() {
                                    if (v == true) {
                                      selectedStudents.add(s.id);
                                    } else {
                                      selectedStudents.remove(s.id);
                                    }
                                  });
                                },
                                title: Text(name),
                                subtitle: Text(email),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final dp = context.read<DataProvider>();
                    if (selectedTeacherId != null) {
                      await dp.assignTeacher(
                        classId,
                        selectedTeacherId!,
                        selectedTeacherName ?? '',
                      );
                    }
                    await dp.updateClass(classId, {
                      'studentIds': selectedStudents.toList(),
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Class updated')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
