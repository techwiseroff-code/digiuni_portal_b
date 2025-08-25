import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/timetable_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageTimetableScreen extends StatefulWidget {
  const AdminManageTimetableScreen({super.key});

  @override
  State<AdminManageTimetableScreen> createState() =>
      _AdminManageTimetableScreenState();
}

class _AdminManageTimetableScreenState
    extends State<AdminManageTimetableScreen> {
  final _dayController = TextEditingController();
  final _subjectController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  String? _selectedClassName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().listenToAllTimetables();
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _subjectController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Timetables')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTimetableDialog,
        child: const Icon(Icons.add),
      ),
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
                onTap: () => _showEditTimetableDialog(t.id, t.className),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<DataProvider>().deleteTimetable(t.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Timetable deleted')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateTimetableDialog() {
    final dp = context.read<DataProvider>();
    _selectedClassName = null;
    _dayController.clear();
    _subjectController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    // ensure classes are loaded
    dp.listenToAllClasses();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Timetable'),
          content: SizedBox(
            width: 420,
            child: Consumer<DataProvider>(
              builder: (context, dp, _) {
                final classes = dp.teacherClasses;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _selectedClassName,
                      isExpanded: true,
                      hint: const Text('Select Class'),
                      items: classes
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.classCode,
                              child: Text('${c.classCode} • ${c.subjectName}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedClassName = v),
                    ),
                    TextField(
                      controller: _dayController,
                      decoration: const InputDecoration(
                        labelText: 'Day (e.g., monday)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'First Slot Subject (optional)',
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(labelText: 'End'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
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
                if (_selectedClassName == null || _dayController.text.isEmpty)
                  return;
                final id = dp.generateId();
                final slots = _subjectController.text.isEmpty
                    ? <TimetableSlot>[]
                    : <TimetableSlot>[
                        TimetableSlot(
                          subject: _subjectController.text.trim(),
                          teacherId: '',
                          teacherName: '',
                          startTime: _startTimeController.text.trim(),
                          endTime: _endTimeController.text.trim(),
                          room: '',
                          notes: null,
                        ),
                      ];
                await dp.createTimetable(
                  TimetableModel(
                    id: id,
                    className: _selectedClassName!,
                    dayOfWeek: _dayController.text.trim(),
                    slots: slots,
                  ),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Timetable created')),
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

  void _showEditTimetableDialog(String timetableId, String className) {
    _subjectController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Slot • $className'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(labelText: 'Start'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(labelText: 'End'),
                    ),
                  ),
                ],
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
                final slot = TimetableSlot(
                  subject: _subjectController.text.trim(),
                  teacherId: '',
                  teacherName: '',
                  startTime: _startTimeController.text.trim(),
                  endTime: _endTimeController.text.trim(),
                  room: '',
                  notes: null,
                );
                final dp = context.read<DataProvider>();
                await dp.updateTimetable(timetableId, {
                  'slots': FieldValue.arrayUnion([slot.toMap()]),
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Slot added')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
