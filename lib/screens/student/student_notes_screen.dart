import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/status_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/note_model.dart';

class StudentNotesScreen extends StatefulWidget {
  const StudentNotesScreen({super.key});

  @override
  State<StudentNotesScreen> createState() => _StudentNotesScreenState();
}

class _StudentNotesScreenState extends State<StudentNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Lecture',
    'Study',
    'Reference',
    'Assignment',
  ];

  @override
  void initState() {
    super.initState();
    // Load notes data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        dataProvider.listenToStudentNotes(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
        child: SafeArea(
          child: Column(
            children: [
              // Clean status bar without notification bell
              const StatusBar(
                title: "Student Portal",
                showNotificationBell: false,
                showBattery: false,
              ),
              const SizedBox(height: 20),

              // Screen Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "My Notes",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white70, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search notes...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Filter Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = filter == _selectedFilter;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header with Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Personal Notes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showAddNoteDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Notes List
                      Expanded(
                        child: Consumer<DataProvider>(
                          builder: (context, dataProvider, child) {
                            if (dataProvider.isLoadingNotes) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            final allNotes = dataProvider.studentNotes;
                            if (allNotes.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No notes found. Create your first note!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            // Apply search filter
                            final searchQuery = _searchController.text
                                .toLowerCase();
                            final filteredNotes = allNotes.where((note) {
                              final matchesSearch =
                                  note.title.toLowerCase().contains(
                                    searchQuery,
                                  ) ||
                                  note.content.toLowerCase().contains(
                                    searchQuery,
                                  );
                              final matchesFilter =
                                  _selectedFilter == 'All' ||
                                  (note.subject == _selectedFilter ||
                                      note.tags == _selectedFilter);
                              return matchesSearch && matchesFilter;
                            }).toList();

                            if (filteredNotes.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No notes match your search criteria',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, index) {
                                return _buildNoteCard(filteredNotes[index]);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Note Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.note, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),

              // Title and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.content,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details Row
          Row(
            children: [
              // Created Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Created: ${_formatDate(note.createdAt)}",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    if (note.updatedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Updated: ${_formatDate(note.updatedAt!)}",
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),

              // Subject Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    note.subject ?? 'Study',
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCategoryColor(
                      note.subject ?? 'Study',
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  note.subject ?? 'Study',
                  style: TextStyle(
                    color: _getCategoryColor(note.subject ?? 'Study'),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Edit Button
              GestureDetector(
                onTap: () => _showEditNoteDialog(context, note),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Colors.white70, size: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Delete Button
              GestureDetector(
                onTap: () => _showDeleteNoteDialog(context, note),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Lecture':
        return Colors.blue;
      case 'Study':
        return Colors.green;
      case 'Reference':
        return Colors.purple;
      case 'Assignment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddNoteDialog(BuildContext context) {
    _titleController.clear();
    _contentController.clear();
    _selectedFilter = 'All';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add New Note',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFilter == 'All' ? null : _selectedFilter,
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.grey[900],
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              items: filters.where((f) => f != 'All').map((filter) {
                return DropdownMenuItem(value: filter, child: Text(filter));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                _addNote();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, NoteModel note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    _selectedFilter = note.subject ?? 'Study';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Edit Note', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.grey[900],
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              items: filters.where((f) => f != 'All').map((filter) {
                return DropdownMenuItem(value: filter, child: Text(filter));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                _updateNote(note);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteDialog(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Note', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${note.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteNote(note);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNote() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final newNote = NoteModel(
        id: '', // Will be generated by Firestore
        studentId: authProvider.currentUser!.uid,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        subject: _selectedFilter == 'All' ? 'Study' : _selectedFilter,
        tags: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dataProvider.createNote(authProvider.currentUser!.uid, newNote);
    }
  }

  void _updateNote(NoteModel note) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final updatedNote = note.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        subject: _selectedFilter == 'All' ? 'Study' : _selectedFilter,
        updatedAt: DateTime.now(),
      );

      dataProvider.updateNote(
        authProvider.currentUser!.uid,
        note.id,
        updatedNote.toMap(),
      );
    }
  }

  void _deleteNote(NoteModel note) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      dataProvider.deleteNote(authProvider.currentUser!.uid, note.id);
    }
  }
}
