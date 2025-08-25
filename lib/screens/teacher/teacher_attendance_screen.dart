import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/class_model.dart';
import '../../models/attendance_model.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _selectedMethod = 'face'; // Changed to face recognition as default
  bool _isFaceRecognitionActive = false;
  final ScrollController _scrollController = ScrollController();
  String? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    // Load teacher's classes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        dataProvider.loadTeacherData(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

              // Class Selection
              _buildClassSelection(),

              // Date Selection
              _buildDateSelection(),

              // Attendance Method Selection
              _buildAttendanceMethod(),

              // Content based on selected method
              Expanded(
                child: _selectedMethod == 'face'
                    ? _buildFaceRecognitionContent()
                    : _buildManualAttendanceContent(),
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
              'Attendance Management',
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
            'Mark Attendance',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track student attendance for your classes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelection() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final classes = dataProvider.teacherClasses;
        
        if (classes.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
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
                      _loadStudentsForClass(value);
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
          ),
        );
      },
    );
  }

  Widget _buildDateSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMethod() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Method',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMethodButton(
                  'face',
                  'Face Recognition',
                  Icons.face,
                  _selectedMethod == 'face',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodButton(
                  'manual',
                  'Manual Entry',
                  Icons.edit,
                  _selectedMethod == 'manual',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(String method, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceRecognitionContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Face Recognition Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  _isFaceRecognitionActive ? Icons.face : Icons.face_retouching_off,
                  color: _isFaceRecognitionActive ? Colors.green : Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _isFaceRecognitionActive ? 'Face Recognition Active' : 'Face Recognition Inactive',
                  style: TextStyle(
                    color: _isFaceRecognitionActive ? Colors.green : Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isFaceRecognitionActive 
                      ? 'Students can mark attendance using face recognition'
                      : 'Tap to activate face recognition for attendance',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isFaceRecognitionActive = !_isFaceRecognitionActive;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFaceRecognitionActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isFaceRecognitionActive ? 'Stop Recognition' : 'Start Recognition',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildManualAttendanceContent() {
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
                'Select a class to mark attendance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
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
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final presentCount = _attendanceStatus.values.where((status) => status).length;
        final absentCount = students.length - presentCount;

        return Column(
          children: [
            // Attendance Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Present',
                      presentCount.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Absent',
                      absentCount.toString(),
                      Colors.red,
                      Icons.cancel,
                    ),
                  ),
                ],
              ),
            ),

            // Student List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final isPresent = _attendanceStatus[student.uid] ?? false;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPresent ? Colors.green.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Student Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isPresent ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(student.name),
                              style: TextStyle(
                                color: isPresent ? Colors.green : Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Student Info
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
                        
                        // Attendance Toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _attendanceStatus[student.uid] = !isPresent;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              color: isPresent ? Colors.green : Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
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
                  onPressed: _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Attendance',
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

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Mark All Present',
                  Icons.check_circle_outline,
                  Colors.green,
                  () => _markAllPresent(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Mark All Absent',
                  Icons.cancel_outlined,
                  Colors.red,
                  () => _markAllAbsent(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _loadStudentsForClass(String? classId) {
    if (classId == null) return;
    
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.loadStudentsForClass(classId);
    
    // Reset attendance status
    setState(() {
      _attendanceStatus.clear();
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _markAllPresent() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final students = dataProvider.students;
    
    setState(() {
      for (final student in students) {
        _attendanceStatus[student.uid] = true;
      }
    });
  }

  void _markAllAbsent() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final students = dataProvider.students;
    
    setState(() {
      for (final student in students) {
        _attendanceStatus[student.uid] = false;
      }
    });
  }

  void _submitAttendance() async {
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
      
      // Create attendance records
      final attendanceRecords = <AttendanceModel>[];
      for (final student in students) {
        final isPresent = _attendanceStatus[student.uid] ?? false;
        attendanceRecords.add(AttendanceModel(
          id: '',
          studentId: student.uid,
          className: dataProvider.teacherClasses.firstWhere((c) => c.id == _selectedClass).classCode,
          subject: dataProvider.teacherClasses.firstWhere((c) => c.id == _selectedClass).subjectName,
          date: _selectedDate,
          status: isPresent ? 'present' : 'absent',
          markedBy: 'teacher',
          markedAt: DateTime.now(),
        ));
      }

      // Submit attendance
      await dataProvider.submitAttendance(attendanceRecords);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting attendance: $e'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
