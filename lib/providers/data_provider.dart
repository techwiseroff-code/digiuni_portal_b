import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../models/performance_model.dart';
import '../models/timetable_model.dart';
import '../models/notification_model.dart';
import '../models/event_model.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Student data
  StudentModel? _currentStudent;
  List<AttendanceModel> _studentAttendance = [];
  List<PerformanceModel> _studentPerformance = [];
  List<NoteModel> _studentNotes = [];
  Map<String, dynamic> _studentSummary = {};

  // Teacher data
  TeacherModel? _currentTeacher;
  List<ClassModel> _teacherClasses = [];
  List<StudentModel> _students = []; // Add students list for teacher use
  Map<String, dynamic> _teacherSummary = {};

  // Shared data
  List<TimetableModel> _timetables = [];
  List<NotificationModel> _notifications = [];
  List<EventModel> _events = [];
  List<UserModel> _users = [];

  // Loading states
  bool _isLoadingStudent = false;
  bool _isLoadingTeacher = false;
  bool _isLoadingAttendance = false;
  bool _isLoadingPerformance = false;
  bool _isLoadingNotes = false;
  bool _isLoadingTimetable = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingEvents = false;

  // Error states
  String? _studentError;
  String? _teacherError;
  String? _attendanceError;
  String? _performanceError;
  String? _timetableError;
  String? _notificationError;
  String? _eventError;

  // Getters
  StudentModel? get currentStudent => _currentStudent;
  List<AttendanceModel> get studentAttendance => _studentAttendance;
  List<PerformanceModel> get studentPerformance => _studentPerformance;
  List<NoteModel> get studentNotes => _studentNotes;
  Map<String, dynamic> get studentSummary => _studentSummary;

  TeacherModel? get currentTeacher => _currentTeacher;
  List<ClassModel> get teacherClasses => _teacherClasses;
  List<StudentModel> get students => _students; // Add getter for students
  Map<String, dynamic> get teacherSummary => _teacherSummary;

  List<TimetableModel> get timetables => _timetables;
  List<NotificationModel> get notifications => _notifications;
  List<EventModel> get events => _events;
  List<UserModel> get users => _users;

  bool get isLoadingStudent => _isLoadingStudent;
  bool get isLoadingTeacher => _isLoadingTeacher;
  bool get isLoadingAttendance => _isLoadingAttendance;
  bool get isLoadingPerformance => _isLoadingPerformance;
  bool get isLoadingNotes => _isLoadingNotes;
  bool get isLoadingTimetable => _isLoadingTimetable;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isLoadingEvents => _isLoadingEvents;

  String? get studentError => _studentError;
  String? get teacherError => _teacherError;
  String? get attendanceError => _attendanceError;
  String? get performanceError => _performanceError;
  String? get timetableError => _timetableError;
  String? get notificationError => _notificationError;
  String? get eventError => _eventError;

  // Student Operations
  Future<void> loadStudentData(String studentId) async {
    try {
      _isLoadingStudent = true;
      _studentError = null;
      notifyListeners();

      _currentStudent = await _firestoreService.getStudent(studentId);
      _studentSummary = await _firestoreService.getStudentSummary(studentId);

      _isLoadingStudent = false;
      notifyListeners();
    } catch (e) {
      _isLoadingStudent = false;
      _studentError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStudentData(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateStudent(studentId, data);
      await loadStudentData(studentId);
    } catch (e) {
      _studentError = e.toString();
      notifyListeners();
    }
  }

  void listenToStudentAttendance(String studentId) {
    _firestoreService
        .getStudentAttendanceStream(studentId)
        .listen(
          (attendance) {
            _studentAttendance = attendance;
            notifyListeners();
          },
          onError: (e) {
            _attendanceError = e.toString();
            notifyListeners();
          },
        );
  }

  void listenToStudentPerformance(String studentId) {
    _firestoreService
        .getStudentPerformanceStream(studentId)
        .listen(
          (performance) {
            _studentPerformance = performance;
            notifyListeners();
          },
          onError: (e) {
            _performanceError = e.toString();
            notifyListeners();
          },
        );
  }

  void listenToStudentNotes(String studentId) {
    _firestoreService
        .getStudentNotesStream(studentId)
        .listen(
          (notes) {
            _studentNotes = notes;
            notifyListeners();
          },
          onError: (e) {
            _studentError = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> createNote(String studentId, NoteModel note) async {
    try {
      _isLoadingNotes = true;
      notifyListeners();

      await _firestoreService.createNote(studentId, note);

      _isLoadingNotes = false;
      notifyListeners();
    } catch (e) {
      _isLoadingNotes = false;
      _studentError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(
    String studentId,
    String noteId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateNote(studentId, noteId, data);
    } catch (e) {
      _studentError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String studentId, String noteId) async {
    try {
      await _firestoreService.deleteNote(studentId, noteId);
    } catch (e) {
      _studentError = e.toString();
      notifyListeners();
    }
  }

  // Teacher Operations
  Future<void> loadTeacherData(String teacherId) async {
    try {
      _isLoadingTeacher = true;
      _teacherError = null;
      notifyListeners();

      _currentTeacher = await _firestoreService.getTeacher(teacherId);
      _teacherSummary = await _firestoreService.getTeacherSummary(teacherId);

      _isLoadingTeacher = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTeacher = false;
      _teacherError = e.toString();
      notifyListeners();
    }
  }

  // Add method to load students for a specific class
  Future<void> loadStudentsForClass(String classId) async {
    try {
      _isLoadingTeacher = true;
      _teacherError = null;
      notifyListeners();

      _students = await _firestoreService.getStudentsForClass(classId);

      _isLoadingTeacher = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTeacher = false;
      _teacherError = e.toString();
      notifyListeners();
    }
  }

  // Add method to submit attendance
  Future<void> submitAttendance(List<AttendanceModel> attendanceRecords) async {
    try {
      _isLoadingAttendance = true;
      _attendanceError = null;
      notifyListeners();

      await _firestoreService.submitAttendance(attendanceRecords);

      _isLoadingAttendance = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAttendance = false;
      _attendanceError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTeacherData(
    String teacherId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateTeacher(teacherId, data);
      await loadTeacherData(teacherId);
    } catch (e) {
      _teacherError = e.toString();
      notifyListeners();
    }
  }

  void listenToTeacherClasses(String teacherId) {
    _firestoreService
        .getTeacherClassesStream(teacherId)
        .listen(
          (classes) {
            _teacherClasses = classes;
            notifyListeners();
          },
          onError: (e) {
            _teacherError = e.toString();
            notifyListeners();
          },
        );
  }

  // Attendance Operations
  Future<void> markAttendance(
    String studentId,
    AttendanceModel attendance,
  ) async {
    try {
      await _firestoreService.markAttendance(studentId, attendance);
    } catch (e) {
      _attendanceError = e.toString();
      notifyListeners();
    }
  }

  Future<void> markBulkAttendance(
    String className,
    String subject,
    DateTime date,
    List<Map<String, dynamic>> attendanceList,
  ) async {
    try {
      await _firestoreService.markBulkAttendance(
        className,
        subject,
        date,
        attendanceList,
      );
    } catch (e) {
      _attendanceError = e.toString();
      notifyListeners();
    }
  }

  // Performance Operations
  Future<void> addPerformance(
    String studentId,
    PerformanceModel performance,
  ) async {
    try {
      await _firestoreService.addPerformance(studentId, performance);
    } catch (e) {
      _performanceError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePerformance(
    String studentId,
    String performanceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updatePerformance(studentId, performanceId, data);
    } catch (e) {
      _performanceError = e.toString();
      notifyListeners();
    }
  }

  // Timetable Operations
  void listenToClassTimetable(String className) {
    _firestoreService
        .getClassTimetableStream(className)
        .listen(
          (timetables) {
            _timetables = timetables;
            notifyListeners();
          },
          onError: (e) {
            _timetableError = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> updateTimetable(
    String timetableId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateTimetable(timetableId, data);
    } catch (e) {
      _timetableError = e.toString();
      notifyListeners();
    }
  }

  Future<void> createTimetable(TimetableModel timetable) async {
    try {
      await _firestoreService.createTimetable(timetable);
    } catch (e) {
      _timetableError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTimetable(String timetableId) async {
    try {
      await _firestoreService.deleteTimetable(timetableId);
    } catch (e) {
      _timetableError = e.toString();
      notifyListeners();
    }
  }

  // Notification Operations
  void listenToUserNotifications(
    String userId, {
    String? role,
    String? className,
  }) {
    _firestoreService
        .getUserNotificationsStream(userId, role: role, className: className)
        .listen(
          (notifications) {
            _notifications = notifications;
            notifyListeners();
          },
          onError: (e) {
            _notificationError = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestoreService.createNotification(notification);
    } catch (e) {
      _notificationError = e.toString();
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
    } catch (e) {
      _notificationError = e.toString();
      notifyListeners();
    }
  }

  // Event Operations
  void listenToEvents({String? targetClass, String? targetRole}) {
    _firestoreService
        .getEventsStream(targetClass: targetClass, targetRole: targetRole)
        .listen(
          (events) {
            _events = events;
            notifyListeners();
          },
          onError: (e) {
            _eventError = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await _firestoreService.createEvent(event);
    } catch (e) {
      _eventError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateEvent(eventId, data);
    } catch (e) {
      _eventError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestoreService.deleteEvent(eventId);
    } catch (e) {
      _eventError = e.toString();
      notifyListeners();
    }
  }

  // Utility Methods
  String generateId() {
    return _firestoreService.generateId();
  }

  void clearErrors() {
    _studentError = null;
    _teacherError = null;
    _attendanceError = null;
    _performanceError = null;
    _timetableError = null;
    _notificationError = null;
    _eventError = null;
    notifyListeners();
  }

  void clearData() {
    _currentStudent = null;
    _currentTeacher = null;
    _studentAttendance = [];
    _studentPerformance = [];
    _studentNotes = [];
    _teacherClasses = [];
    _timetables = [];
    _notifications = [];
    _events = [];
    _users = [];
    _studentSummary = {};
    _teacherSummary = {};
    notifyListeners();
  }

  // Admin listeners/actions
  void listenToUsers({String? role}) {
    _firestoreService
        .getUsersStream(role: role)
        .listen(
          (list) {
            _users = list;
            notifyListeners();
          },
          onError: (e) {
            _teacherError = e.toString();
            notifyListeners();
          },
        );
  }

  void listenToAllClasses() {
    _firestoreService.getAllClassesStream().listen(
      (list) {
        _teacherClasses = list;
        notifyListeners();
      },
      onError: (e) {
        _teacherError = e.toString();
        notifyListeners();
      },
    );
  }

  void listenToAllTimetables() {
    _firestoreService.getAllTimetablesStream().listen(
      (list) {
        _timetables = list;
        notifyListeners();
      },
      onError: (e) {
        _timetableError = e.toString();
        notifyListeners();
      },
    );
  }

  void listenToAllEvents() {
    _firestoreService.getAllEventsStream().listen(
      (list) {
        _events = list;
        notifyListeners();
      },
      onError: (e) {
        _eventError = e.toString();
        notifyListeners();
      },
    );
  }

  void listenToAllNotifications() {
    _firestoreService.getAllNotificationsStream().listen(
      (list) {
        _notifications = list;
        notifyListeners();
      },
      onError: (e) {
        _notificationError = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> deleteClass(String classId) async {
    await _firestoreService.deleteClass(classId);
  }

  Future<void> createClass(Map<String, dynamic> classData) async {
    await _firestoreService.createClass(classData);
  }

  Future<void> updateClass(String classId, Map<String, dynamic> data) async {
    await _firestoreService.updateClass(classId, data);
  }

  Future<Map<String, int>> getSystemStats() async {
    return _firestoreService.getSystemStats();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestoreService.deleteNotification(notificationId);
  }

  // Admin helpers
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestoreService.updateUser(uid, data);
  }

  Future<void> deleteUser(String uid) async {
    await _firestoreService.deleteUser(uid);
  }

  Future<void> enrollStudents(String classId, List<String> studentIds) async {
    await _firestoreService.enrollStudents(classId, studentIds);
  }

  Future<void> removeStudent(String classId, String studentId) async {
    await _firestoreService.removeStudent(classId, studentId);
  }

  Future<void> assignTeacher(
    String classId,
    String teacherId,
    String teacherName,
  ) async {
    await _firestoreService.assignTeacher(classId, teacherId, teacherName);
  }
}
