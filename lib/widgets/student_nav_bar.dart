import 'package:flutter/material.dart';

class StudentNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StudentNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Timetable'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Attendance'),
      ],
    );
  }
}