import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  String _filterRole = 'all';
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _newRole = 'student';
  final _passwordController = TextEditingController();
  final _editNameController = TextEditingController();
  final _editEmailController = TextEditingController();
  String? _editingRole;
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().listenToUsers();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _editNameController.dispose();
    _editEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _filterRole,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: 'student',
                          child: Text('Students'),
                        ),
                        DropdownMenuItem(
                          value: 'teacher',
                          child: Text('Teachers'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admins')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _filterRole = v);
                        context.read<DataProvider>().listenToUsers(
                          role: v == 'all' ? null : v,
                        );
                      },
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _downloadTemplate(isTeacher: false),
                      icon: const Icon(Icons.download),
                      label: const Text('Student Template'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _importExcel(isTeacher: false),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Students (Excel)'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _downloadTemplate(isTeacher: true),
                      icon: const Icon(Icons.download),
                      label: const Text('Teacher Template'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _importExcel(isTeacher: true),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Teachers (Excel)'),
                    ),
                  ],
                ),
                if (_selectedUserIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton.icon(
                      onPressed: _confirmBulkDelete,
                      icon: const Icon(Icons.delete_forever),
                      label: Text(
                        'Delete Selected (${_selectedUserIds.length})',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, dp, _) {
                final users = dp.users;
                if (users.isEmpty) {
                  return const Center(child: Text('No users'));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return ListTile(
                      leading: Checkbox(
                        value: _selectedUserIds.contains(u.uid),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedUserIds.add(u.uid);
                            } else {
                              _selectedUserIds.remove(u.uid);
                            }
                          });
                        },
                      ),
                      title: Text(u.name),
                      subtitle: Text('${u.email} • ${u.role}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditUserDialog(
                              u.uid,
                              u.name,
                              u.email,
                              u.role,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _confirmDeleteSingle(u.uid, u.email),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _newRole,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _newRole = v ?? 'student'),
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
                final auth = context.read<AuthProvider>();
                final ok = await auth.createUserAccount(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                  name: _nameController.text.trim(),
                  role: _newRole,
                );
                if (mounted) {
                  Navigator.pop(context);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User created')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(auth.error ?? 'Failed')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(
    String uid,
    String currentName,
    String currentEmail,
    String currentRole,
  ) {
    _editNameController.text = currentName;
    _editEmailController.text = currentEmail;
    _editingRole = currentRole;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editNameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _editEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _editingRole,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _editingRole = v),
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
                await context.read<DataProvider>().updateUser(uid, {
                  'name': _editNameController.text.trim(),
                  'role': _editingRole ?? currentRole,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('User updated')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadTemplate({required bool isTeacher}) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    final headers = isTeacher
        ? [
            'Name',
            'EmployeeId',
            'Department',
            'ContactNumber',
            'Email',
            'Password',
          ]
        : ['Name', 'RollNo', 'Address', 'ContactNumber', 'Email', 'Password'];
    sheet.insertRowIterables(headers.map((h) => TextCellValue(h)).toList(), 0);
    for (int i = 0; i < headers.length; i++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        TextCellValue(headers[i]),
        cellStyle: CellStyle(bold: true),
      );
    }
    final bytes = excel.encode()!;
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${isTeacher ? 'teacher_template' : 'student_template'}.xlsx',
    );
    await file.writeAsBytes(bytes, flush: true);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Template saved to ${file.path}')));
    }
  }

  Future<void> _importExcel({required bool isTeacher}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final bytes = await File(path).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final table = excel.tables[excel.tables.keys.first];
    if (table == null) return;
    final headers = table.rows.first
        .map((c) => (c?.value ?? '').toString().trim())
        .toList();
    final expected = isTeacher
        ? [
            'Name',
            'EmployeeId',
            'Department',
            'ContactNumber',
            'Email',
            'Password',
          ]
        : ['Name', 'RollNo', 'Address', 'ContactNumber', 'Email', 'Password'];
    for (final h in expected) {
      if (!headers.contains(h)) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Missing column: $h')));
        }
        return;
      }
    }
    final rows = <Map<String, String>>[];
    for (int r = 1; r < table.maxRows; r++) {
      final row = <String, String>{};
      for (int c = 0; c < headers.length; c++) {
        final key = headers[c];
        final val = table.rows[r][c]?.value?.toString().trim() ?? '';
        row[key] = val;
      }
      rows.add(row);
    }
    _showPreviewDialog(rows: rows, isTeacher: isTeacher, expected: expected);
  }

  void _showPreviewDialog({
    required List<Map<String, String>> rows,
    required bool isTeacher,
    required List<String> expected,
  }) {
    final List<Map<String, String>> working = List<Map<String, String>>.from(
      rows,
    );
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Preview ${isTeacher ? 'Teachers' : 'Students'}'),
              content: SizedBox(
                width: 600,
                height: 420,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: working.length,
                        itemBuilder: (context, index) {
                          final row = working[index];
                          final missingRequired =
                              (row['Name']?.isEmpty ?? true) ||
                              (row['Email']?.isEmpty ?? true);
                          final hasPassword =
                              row['Password'] != null &&
                              row['Password']!.isNotEmpty;
                          return Card(
                            color: missingRequired
                                ? Colors.red.withOpacity(0.08)
                                : null,
                            child: ListTile(
                              title: Text(row['Name'] ?? ''),
                              subtitle: Text(
                                '${row['Email'] ?? ''} • ${isTeacher ? (row['EmployeeId'] ?? '') : (row['RollNo'] ?? '')}',
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  if (!hasPassword)
                                    const Chip(label: Text('Default Password')),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () {
                                      setStateDialog(() {
                                        working.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                    await _confirmImport(working, isTeacher: isTeacher);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Import complete')),
                      );
                    }
                  },
                  child: const Text('Confirm Import'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmImport(
    List<Map<String, String>> rows, {
    required bool isTeacher,
  }) async {
    final auth = context.read<AuthProvider>();
    for (final row in rows) {
      final name = row['Name']?.trim() ?? '';
      final email = row['Email']?.trim() ?? '';
      String password = row['Password']?.trim() ?? '';
      if (name.isEmpty || email.isEmpty) {
        continue;
      }
      if (password.isEmpty) {
        password = isTeacher ? 'teacher@123' : 'student@123';
      }
      final ok = await auth.createUserAccount(
        email: email,
        password: password,
        name: name,
        role: isTeacher ? 'teacher' : 'student',
      );
      if (!ok) {
        continue;
      }
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (q.docs.isEmpty) continue;
      final uid = q.docs.first.id;
      final map = <String, dynamic>{
        'name': name,
        'email': email,
        'contactNumber': row['ContactNumber'] ?? '',
      };
      if (isTeacher) {
        map['department'] = row['Department'] ?? '';
        map['employeeId'] = row['EmployeeId'] ?? '';
      } else {
        map['address'] = row['Address'] ?? '';
        map['rollNo'] = row['RollNo'] ?? '';
      }
      await context.read<DataProvider>().updateUser(uid, map);
    }
  }

  Future<void> _confirmDeleteSingle(String uid, String email) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await context.read<DataProvider>().deleteUser(uid);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User deleted')));
    }
  }

  Future<void> _confirmBulkDelete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Selected Users'),
        content: Text(
          'Are you sure you want to delete ${_selectedUserIds.length} selected users?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    final dp = context.read<DataProvider>();
    for (final uid in _selectedUserIds.toList()) {
      await dp.deleteUser(uid);
    }
    setState(() => _selectedUserIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selected users deleted')));
    }
  }
}
