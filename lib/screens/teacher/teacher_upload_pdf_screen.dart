import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/class_model.dart';
import '../../models/event_model.dart';

class TeacherResourcesScreen extends StatefulWidget {
  const TeacherResourcesScreen({super.key});

  @override
  State<TeacherResourcesScreen> createState() => _TeacherResourcesScreenState();
}

class _TeacherResourcesScreenState extends State<TeacherResourcesScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedClass;
  String _selectedResourceType = 'text';
  bool _isLoading = false;
  bool _isCreating = false;

  final List<String> _resourceTypes = ['text', 'link', 'document'];

  @override
  void initState() {
    super.initState();
    // Load teacher's classes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        dataProvider.loadTeacherData(authProvider.currentUser!.uid);
        dataProvider.listenToTeacherClasses(authProvider.currentUser!.uid);
        // Ensure resources list stays real-time
        dataProvider.listenToEvents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Status Bar
              _buildTopBar(),

              // Screen Title
              _buildScreenTitle(),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Learning Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isCreating = !_isCreating;
                if (!_isCreating) {
                  _clearForm();
                }
              });
            },
            icon: Icon(
              _isCreating ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Resources',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create and manage text-based learning materials for your students',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isCreating) {
      return _buildCreateForm();
    }

    return _buildResourcesList();
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Type Selection
            _buildDropdownField(
              label: 'Resource Type',
              icon: Icons.category,
              value: _selectedResourceType,
              items: _resourceTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedResourceType = value ?? 'text';
                });
              },
            ),

            const SizedBox(height: 20),

            // Class Selection
            Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final classes = dataProvider.teacherClasses;

                if (classes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Center(
                      child: Text(
                        'No classes assigned yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }

                return _buildDropdownField(
                  label: 'Target Class',
                  icon: Icons.class_,
                  value: _selectedClass,
                  items: classes.map((cls) {
                    return DropdownMenuItem<String>(
                      value: cls.id,
                      child: Text(
                        '${cls.classCode} - ${cls.subjectName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Title Field
            _buildFormField(
              controller: _titleController,
              label: 'Resource Title',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter resource title';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Description Field
            _buildFormField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Content Field
            _buildFormField(
              controller: _contentController,
              label: _selectedResourceType == 'link' ? 'URL/Link' : 'Content',
              icon: _selectedResourceType == 'link'
                  ? Icons.link
                  : Icons.article,
              maxLines: _selectedResourceType == 'text' ? 8 : 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                if (_selectedResourceType == 'link' && !_isValidUrl(value)) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createResource,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Resource',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesList() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoadingEvents) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final resources = dataProvider.events
            .where(
              (event) => event.type == 'assignment' || event.type == 'event',
            )
            .toList();

        if (resources.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.article, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No resources created yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first learning resource',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return _buildResourceCard(resource);
          },
        );
      },
    );
  }

  Widget _buildResourceCard(EventModel resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getResourceIcon(resource.type),
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.type[0].toUpperCase() +
                          resource.type.substring(1),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(resource.createdAt),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          if (resource.description.isNotEmpty) ...[
            Text(
              resource.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],

          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _viewResource(resource),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: const Text('View Details'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _editResource(resource),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  child: const Text('Edit'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _deleteResource(resource.id),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(icon, color: Colors.white70, size: 20),
            ),
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(icon, color: Colors.white70, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _descriptionController.clear();
    _selectedClass = null;
    _selectedResourceType = 'text';
  }

  void _createResource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a target class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        final resource = EventModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: 'assignment',
          date: DateTime.now(),
          startTime: null,
          endTime: null,
          location: null,
          targetClass: _selectedClass,
          targetRole: 'student',
          createdBy: authProvider.currentUser!.uid,
          createdByName: dataProvider.currentTeacher?.name ?? 'Teacher',
          createdByRole: 'teacher',
          createdAt: DateTime.now(),
          isActive: true,
          attachmentUrl: _contentController.text.trim(),
          attachmentType: _selectedResourceType,
          metadata: {
            'resourceType': _selectedResourceType,
            'content': _contentController.text.trim(),
          },
        );

        await dataProvider.createEvent(resource);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isCreating = false;
        });
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating resource: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewResource(EventModel resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          resource.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resource.description,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (resource.metadata?['content'] != null) ...[
                const Text(
                  'Content:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resource.metadata!['content'],
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editResource(EventModel resource) {
    _titleController.text = resource.title;
    _descriptionController.text = resource.description;
    _contentController.text = resource.metadata?['content'] ?? '';
    _selectedResourceType = resource.metadata?['resourceType'] ?? 'text';
    _selectedClass = resource.targetClass;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Resource',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Content / Link',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              await dataProvider.updateEvent(resource.id, {
                'title': _titleController.text.trim(),
                'description': _descriptionController.text.trim(),
                'metadata': {
                  'resourceType': _selectedResourceType,
                  'content': _contentController.text.trim(),
                },
                'updatedAt': DateTime.now(),
              });
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resource updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteResource(String resourceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Resource',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this resource?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final dataProvider = Provider.of<DataProvider>(
                  context,
                  listen: false,
                );
                await dataProvider.deleteEvent(resourceId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resource deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting resource: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'event':
        return Icons.event;
      default:
        return Icons.article;
    }
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
