import 'package:flutter/material.dart';
import '../utils/styles.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/student/student_attendance_screen.dart';
import '../screens/student/student_timetable_screen.dart';

import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/teacher_profile_screen.dart';
import '../screens/teacher/teacher_attendance_screen.dart';
import '../screens/teacher/teacher_timetable_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isTeacher;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> items = isTeacher
        ? const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
      BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Attendance'),
    ]
        : const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Timetable'),
      BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Attendance'),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index); // state update (external)
        _handleNavigation(context, index);
      },
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.white70,
      backgroundColor: Styles.cardDark.withAlpha(180),
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (isTeacher) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()));
          break;
        case 1:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const TeacherProfileScreen()));
          break;
        case 2:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const TeacherTimetableScreen()));
          break;
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const TeacherAttendanceScreen()));
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const StudentDashboardScreen()));
          break;
        case 1:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
          break;
        case 2:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const StudentTimetableScreen()));
          break;
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const StudentAttendanceScreen()));
          break;
      }
    }
  }
}
