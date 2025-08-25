import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import '../../models/performance_model.dart';

class TeacherGradesScreen extends StatefulWidget {
  const TeacherGradesScreen({super.key});

  @override
  State<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends State<TeacherGradesScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedClass;
  String? _selectedSubject;
  final Map<String, TextEditingController> _gradeControllers = {};
  final Map<String, TextEditingController> _remarksControllers = {};

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
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dispose all text controllers
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    for (var controller in _remarksControllers.values) {
      controller.dispose();
    }
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

              // Class and Subject Selection
              _buildSelectionSection(),

              // Students List with Grades
              Expanded(
                child: _buildStudentsList(),
              ),
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
              'Grade Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
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
            'Grade Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload and manage student grades for your classes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Class',
                    style: TextStyle(
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
                          _selectedSubject = null;
                          _clearControllers();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Choose a class',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Subject Selection (auto-populated from class)
          if (_selectedClass != null)
            Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final selectedClass = dataProvider.teacherClasses
                    .firstWhere((c) => c.id == _selectedClass);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subject',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.book, color: Colors.white70, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            selectedClass.subjectName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_selectedClass == null) {
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
              Icon(Icons.class_, color: Colors.white70, size: 48),
              SizedBox(height: 16),
              Text(
                'Select a class to manage grades',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoadingTeacher) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        final students = dataProvider.students;
        
        if (students.isEmpty) {
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
                  Icon(Icons.people, color: Colors.white70, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No students found in this class',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.grade, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${students.length} Students • Enter grades and remarks',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Students List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _buildStudentGradeCard(student);
                },
              ),
            ),

            // Submit Button
            Container(
              margin: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitGrades,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Grades',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentGradeCard(StudentModel student) {
    // Initialize controllers if they don't exist
    if (!_gradeControllers.containsKey(student.uid)) {
      _gradeControllers[student.uid] = TextEditingController();
    }
    if (!_remarksControllers.containsKey(student.uid)) {
      _remarksControllers[student.uid] = TextEditingController();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Student Info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _getInitials(student.name),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.studentId,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grade Input
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grade',
                      style: TextStyle(
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
                      child: TextField(
                        controller: _gradeControllers[student.uid]!,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: 'A, B, C, D, F',
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Remarks',
                      style: TextStyle(
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
                      child: TextField(
                        controller: _remarksControllers[student.uid]!,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: 'Optional remarks',
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    for (var controller in _gradeControllers.values) {
      controller.clear();
    }
    for (var controller in _remarksControllers.values) {
      controller.clear();
    }
  }

  void _submitGrades() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final students = dataProvider.students;
      final selectedClass = dataProvider.teacherClasses
          .firstWhere((c) => c.id == _selectedClass);
      
      // Create performance records
      final performanceRecords = <PerformanceModel>[];
      for (final student in students) {
        final grade = _gradeControllers[student.uid]?.text.trim();
        final remarks = _remarksControllers[student.uid]?.text.trim();
        
        if (grade != null && grade.isNotEmpty) {
          performanceRecords.add(PerformanceModel(
            id: '',
            studentId: student.uid,
            className: selectedClass.classCode,
            subject: selectedClass.subjectName,
            examType: 'assignment',
            marks: 0.0, // This will be calculated based on grade
            totalMarks: 100.0,
            grade: grade,
            remarks: remarks,
            markedBy: dataProvider.currentTeacher?.uid ?? '',
            examDate: DateTime.now(),
            markedAt: DateTime.now(),
          ));
        }
      }

      if (performanceRecords.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one grade'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Submit grades
      for (final record in performanceRecords) {
        await dataProvider.addPerformance(record.studentId, record);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grades submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear controllers after successful submission
      _clearControllers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting grades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
