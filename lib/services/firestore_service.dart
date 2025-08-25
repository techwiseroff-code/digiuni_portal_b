import 'package:cloud_firestore/cloud_firestore.dart';
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

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Student Operations
  Future<StudentModel?> getStudent(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('students')
          .doc(uid)
          .get();
      if (doc.exists) {
        return StudentModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStudent(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('students').doc(uid).update(data);
  }

  // Teacher Operations
  Future<TeacherModel?> getTeacher(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('teachers')
          .doc(uid)
          .get();
      if (doc.exists) {
        return TeacherModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTeacher(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('teachers').doc(uid).update(data);
  }

  // Attendance Operations
  Stream<List<AttendanceModel>> getStudentAttendanceStream(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('attendance')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markAttendance(
    String studentId,
    AttendanceModel attendance,
  ) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('attendance')
        .doc(attendance.id)
        .set(attendance.toMap());
  }

  Future<void> markBulkAttendance(
    String className,
    String subject,
    DateTime date,
    List<Map<String, dynamic>> attendanceList,
  ) async {
    WriteBatch batch = _firestore.batch();

    for (var attendance in attendanceList) {
      String studentId = attendance['studentId'];
      DocumentReference docRef = _firestore
          .collection('students')
          .doc(studentId)
          .collection('attendance')
          .doc('${studentId}_${date.millisecondsSinceEpoch}');

      batch.set(docRef, attendance);
    }

    await batch.commit();
  }

  // Add method to get students for a specific class
  Future<List<StudentModel>> getStudentsForClass(String classId) async {
    try {
      // Get the class document to find enrolled students
      DocumentSnapshot classDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .get();

      if (!classDoc.exists) return [];

      Map<String, dynamic> classData = classDoc.data() as Map<String, dynamic>;
      List<String> studentIds = List<String>.from(
        classData['studentIds'] ?? [],
      );

      if (studentIds.isEmpty) return [];

      // Get all student documents
      List<StudentModel> students = [];
      for (String studentId in studentIds) {
        StudentModel? student = await getStudent(studentId);
        if (student != null) {
          students.add(student);
        }
      }

      return students;
    } catch (e) {
      return [];
    }
  }

  // Add method to submit attendance for multiple students
  Future<void> submitAttendance(List<AttendanceModel> attendanceRecords) async {
    WriteBatch batch = _firestore.batch();

    for (var attendance in attendanceRecords) {
      String docId =
          '${attendance.studentId}_${attendance.date.millisecondsSinceEpoch}';
      DocumentReference docRef = _firestore
          .collection('students')
          .doc(attendance.studentId)
          .collection('attendance')
          .doc(docId);

      batch.set(docRef, attendance.toMap());
    }

    await batch.commit();
  }

  // Performance Operations
  Stream<List<PerformanceModel>> getStudentPerformanceStream(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('performance')
        .orderBy('examDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PerformanceModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addPerformance(
    String studentId,
    PerformanceModel performance,
  ) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('performance')
        .doc(performance.id)
        .set(performance.toMap());
  }

  Future<void> updatePerformance(
    String studentId,
    String performanceId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('performance')
        .doc(performanceId)
        .update(data);
  }

  // Timetable Operations
  Stream<List<TimetableModel>> getClassTimetableStream(String className) {
    return _firestore
        .collection('timetables')
        .where('className', isEqualTo: className)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TimetableModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateTimetable(
    String timetableId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('timetables').doc(timetableId).update(data);
  }

  Future<void> createTimetable(TimetableModel timetable) async {
    await _firestore
        .collection('timetables')
        .doc(timetable.id)
        .set(timetable.toMap());
  }

  // Notification Operations
  Stream<List<NotificationModel>> getUserNotificationsStream(
    String userId, {
    String? role,
    String? className,
  }) {
    Query query = _firestore.collection('notifications');

    // Add filters based on role and class
    if (role != null) {
      query = query.where('targetRole', whereIn: [role, 'all']);
    }
    if (className != null) {
      query = query.where('targetClass', whereIn: [className, null]);
    }

    return query
        .where('targetUserId', whereIn: [userId, null])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NotificationModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Event Operations
  Stream<List<EventModel>> getEventsStream({
    String? targetClass,
    String? targetRole,
  }) {
    Query query = _firestore
        .collection('events')
        .where('isActive', isEqualTo: true);

    if (targetClass != null) {
      query = query.where('targetClass', whereIn: [targetClass, null]);
    }
    if (targetRole != null) {
      query = query.where('targetRole', whereIn: [targetRole, 'all']);
    }

    return query
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EventModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> createEvent(EventModel event) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _firestore.collection('events').doc(eventId).update(data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  // Note Operations
  Stream<List<NoteModel>> getStudentNotesStream(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createNote(String studentId, NoteModel note) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('notes')
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> updateNote(
    String studentId,
    String noteId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('notes')
        .doc(noteId)
        .update(data);
  }

  Future<void> deleteNote(String studentId, String noteId) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // Class Operations
  Stream<List<ClassModel>> getTeacherClassesStream(String teacherId) {
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createClass(Map<String, dynamic> classData) async {
    await _firestore.collection('classes').add(classData);
  }

  Future<void> updateClass(String classId, Map<String, dynamic> data) async {
    await _firestore.collection('classes').doc(classId).update(data);
  }

  Future<void> deleteClass(String classId) async {
    await _firestore.collection('classes').doc(classId).delete();
  }

  // Utility Methods
  String generateId() {
    return _firestore.collection('temp').doc().id;
  }

  // Admin: Users stream
  Stream<List<UserModel>> getUsersStream({String? role}) {
    Query query = _firestore.collection('users');
    if (role != null && role.isNotEmpty) {
      query = query.where('role', isEqualTo: role);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  // Admin: All classes stream
  Stream<List<ClassModel>> getAllClassesStream() {
    return _firestore
        .collection('classes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ClassModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Admin: All timetables stream
  Stream<List<TimetableModel>> getAllTimetablesStream() {
    return _firestore
        .collection('timetables')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TimetableModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Admin: All notifications stream
  Stream<List<NotificationModel>> getAllNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NotificationModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Admin: All events stream
  Stream<List<EventModel>> getAllEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EventModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Admin: System stats
  Future<Map<String, int>> getSystemStats() async {
    final usersSnap = await _firestore.collection('users').get();
    final students = usersSnap.docs
        .where((d) => (d.data() as Map<String, dynamic>)['role'] == 'student')
        .length;
    final teachers = usersSnap.docs
        .where((d) => (d.data() as Map<String, dynamic>)['role'] == 'teacher')
        .length;
    final admins = usersSnap.docs
        .where((d) => (d.data() as Map<String, dynamic>)['role'] == 'admin')
        .length;
    final classesSnap = await _firestore.collection('classes').get();
    final eventsSnap = await _firestore.collection('events').get();
    final notificationsSnap = await _firestore
        .collection('notifications')
        .get();
    return {
      'students': students,
      'teachers': teachers,
      'admins': admins,
      'classes': classesSnap.docs.length,
      'events': eventsSnap.docs.length,
      'notifications': notificationsSnap.docs.length,
    };
  }

  Future<Map<String, dynamic>> getStudentSummary(String studentId) async {
    try {
      // Get attendance count
      QuerySnapshot attendanceSnapshot = await _firestore
          .collection('students')
          .doc(studentId)
          .collection('attendance')
          .get();

      int totalDays = attendanceSnapshot.docs.length;
      int presentDays = attendanceSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['status'] == 'present';
      }).length;

      // Get performance average
      QuerySnapshot performanceSnapshot = await _firestore
          .collection('students')
          .doc(studentId)
          .collection('performance')
          .get();

      double totalMarks = 0;
      double totalPossibleMarks = 0;

      for (var doc in performanceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          totalMarks += (data['marks'] ?? 0).toDouble();
          totalPossibleMarks += (data['totalMarks'] ?? 100).toDouble();
        }
      }

      double averagePercentage = totalPossibleMarks > 0
          ? (totalMarks / totalPossibleMarks) * 100
          : 0;

      // Get unread notifications count
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('targetUserId', whereIn: [studentId, null])
          .where('isRead', isEqualTo: false)
          .get();

      return {
        'attendancePercentage': totalDays > 0
            ? (presentDays / totalDays) * 100
            : 0,
        'averagePerformance': averagePercentage,
        'unreadNotifications': notificationsSnapshot.docs.length,
        'totalClasses': totalDays,
      };
    } catch (e) {
      return {
        'attendancePercentage': 0,
        'averagePerformance': 0,
        'unreadNotifications': 0,
        'totalClasses': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getTeacherSummary(String teacherId) async {
    try {
      // Get assigned classes count
      QuerySnapshot classesSnapshot = await _firestore
          .collection('classes')
          .where('assignedTeacher', isEqualTo: teacherId)
          .get();

      // Get pending attendance tasks
      QuerySnapshot attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('markedBy', isEqualTo: teacherId)
          .where(
            'date',
            isEqualTo: DateTime.now().toIso8601String().split('T')[0],
          )
          .get();

      // Get unread notifications count
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('targetUserId', whereIn: [teacherId, null])
          .where('isRead', isEqualTo: false)
          .get();

      return {
        'assignedClasses': classesSnapshot.docs.length,
        'pendingAttendance': attendanceSnapshot.docs.length,
        'unreadNotifications': notificationsSnapshot.docs.length,
      };
    } catch (e) {
      return {
        'assignedClasses': 0,
        'pendingAttendance': 0,
        'unreadNotifications': 0,
      };
    }
  }
}
