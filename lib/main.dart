import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'utils/styles.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';

// Auth Screens
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/student_login_screen.dart';
import 'screens/auth/teacher_login_screen.dart';

// Student Screens
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_profile_screen.dart';
import 'screens/student/student_notes_screen.dart';
import 'screens/student/student_id_card_screen.dart';
import 'screens/student/student_attendance_screen.dart';
import 'screens/student/student_timetable_screen.dart';
import 'screens/student/student_performance_screen.dart';
import 'screens/student/student_ai_chat_screen.dart';
import 'screens/student/student_notifications_screen.dart';

// Teacher Screens
import 'screens/teacher/teacher_dashboard_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'screens/teacher/teacher_profile_screen.dart';
import 'screens/teacher/teacher_classes_screen.dart';
import 'screens/teacher/teacher_attendance_screen.dart';
import 'screens/teacher/teacher_grades_screen.dart';
import 'screens/teacher/teacher_upload_marks_screen.dart';
import 'screens/teacher/teacher_upload_pdf_screen.dart';
import 'screens/teacher/teacher_add_event_screen.dart';
import 'screens/teacher/teacher_notifications_screen.dart';

// Admin Screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_manage_users_screen.dart';
import 'screens/admin/admin_manage_classes_screen.dart';
import 'screens/admin/admin_manage_timetable_screen.dart';
import 'screens/admin/admin_manage_announcements_screen.dart';
import 'screens/admin/admin_manage_notifications_screen.dart';
import 'screens/admin/admin_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DigiUniApp());
}

class DigiUniApp extends StatelessWidget {
  const DigiUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'DigiUni Portal',
        debugShowCheckedModeBanner: false,
        theme: Styles.appTheme,
        initialRoute: '/',
        routes: {
          // 🔐 Auth
          '/': (context) => const RoleSelectionScreen(),
          '/student/login': (context) => const StudentLoginScreen(),
          '/teacher/login': (context) => const TeacherLoginScreen(),

          // 🎓 Student Routes
          '/student/dashboard': (context) => const StudentDashboardScreen(),
          '/student/profile': (context) => const StudentProfileScreen(),
          '/student/notes': (context) => const StudentNotesScreen(),
          '/student/id_card': (context) => const StudentIDCardScreen(),
          '/student/attendance': (context) => const StudentAttendanceScreen(),
          '/student/timetable': (context) => const StudentTimetableScreen(),
          '/student/performance': (context) => const StudentPerformanceScreen(),
          '/student/ai_chat': (context) => const StudentAIChatScreen(),
          '/notifications': (context) => const StudentNotificationsScreen(),

          // 🧑‍🏫 Teacher Routes
          '/teacher/dashboard': (context) => const TeacherDashboardScreen(),
          '/teacher/home': (context) => const TeacherHomeScreen(),
          '/teacher/profile': (context) => const TeacherProfileScreen(),
          '/teacher/classes': (context) => const TeacherClassesScreen(),
          '/teacher/attendance': (context) => const TeacherAttendanceScreen(),
          '/teacher/grades': (context) => const TeacherGradesScreen(),
          '/teacher/upload-marks': (context) =>
              const TeacherUploadMarksScreen(),
          '/teacher/upload-pdf': (context) => const TeacherResourcesScreen(),
          '/teacher/add-event': (context) => const TeacherAddEventScreen(),
          '/teacher/notifications': (context) =>
              const TeacherNotificationsScreen(),

          // 👑 Admin Routes
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
          '/admin/users': (context) => const AdminManageUsersScreen(),
          '/admin/classes': (context) => const AdminManageClassesScreen(),
          '/admin/timetable': (context) => const AdminManageTimetableScreen(),
          '/admin/announcements': (context) =>
              const AdminManageAnnouncementsScreen(),
          '/admin/notifications': (context) =>
              const AdminManageNotificationsScreen(),
          '/admin/reports': (context) => const AdminReportsScreen(),
        },
      ),
    );
  }
}
