import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

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
            child: DropdownButton<String>(
              value: _filterRole,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'student', child: Text('Students')),
                DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
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
                      leading: CircleAvatar(
                        child: Text(u.name.isNotEmpty ? u.name[0] : '?'),
                      ),
                      title: Text(u.name),
                      subtitle: Text('${u.email} • ${u.role}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditUserDialog(u.uid, u.name, u.email, u.role);
                          } else if (value == 'delete') {
                            await context.read<DataProvider>().deleteUser(
                              u.uid,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User deleted')),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
