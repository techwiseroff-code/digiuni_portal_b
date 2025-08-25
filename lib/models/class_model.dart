import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String classCode;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final List<TimetableSlot> schedule;
  final String room;
  final String? description;
  final DateTime createdAt;
  final bool isActive;

  ClassModel({
    required this.id,
    required this.classCode,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.studentIds,
    required this.schedule,
    required this.room,
    this.description,
    required this.createdAt,
    this.isActive = true,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      classCode: map['classCode'] ?? '',
      subjectName: map['subjectName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      schedule:
          (map['schedule'] as List<dynamic>?)
              ?.map((slot) => TimetableSlot.fromMap(slot))
              .toList() ??
          [],
      room: map['room'] ?? '',
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classCode': classCode,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentIds': studentIds,
      'schedule': schedule.map((slot) => slot.toMap()).toList(),
      'room': room,
      'description': description,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  ClassModel copyWith({
    String? id,
    String? classCode,
    String? subjectName,
    String? teacherId,
    String? teacherName,
    List<String>? studentIds,
    List<TimetableSlot>? schedule,
    String? room,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ClassModel(
      id: id ?? this.id,
      classCode: classCode ?? this.classCode,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TimetableSlot {
  final String subject;
  final String teacherId;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String room;
  final int dayOfWeek; // 1 = Monday, 2 = Tuesday, etc.
  final String? notes;

  TimetableSlot({
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.dayOfWeek,
    this.notes,
  });

  factory TimetableSlot.fromMap(Map<String, dynamic> map) {
    return TimetableSlot(
      subject: map['subject'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      room: map['room'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? 1,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'notes': notes,
    };
  }

  TimetableSlot copyWith({
    String? subject,
    String? teacherId,
    String? teacherName,
    String? startTime,
    String? endTime,
    String? room,
    int? dayOfWeek,
    String? notes,
  }) {
    return TimetableSlot(
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      notes: notes ?? this.notes,
    );
  }
}
