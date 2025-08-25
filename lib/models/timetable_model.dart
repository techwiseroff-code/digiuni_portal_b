import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableModel {
  final String id;
  final String className;
  final String dayOfWeek; // 'monday', 'tuesday', etc.
  final List<TimetableSlot> slots;

  TimetableModel({
    required this.id,
    required this.className,
    required this.dayOfWeek,
    required this.slots,
  });

  factory TimetableModel.fromMap(Map<String, dynamic> map, String id) {
    return TimetableModel(
      id: id,
      className: map['className'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      slots: (map['slots'] as List<dynamic>?)
              ?.map((slot) => TimetableSlot.fromMap(slot))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'dayOfWeek': dayOfWeek,
      'slots': slots.map((slot) => slot.toMap()).toList(),
    };
  }

  TimetableModel copyWith({
    String? id,
    String? className,
    String? dayOfWeek,
    List<TimetableSlot>? slots,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      className: className ?? this.className,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      slots: slots ?? this.slots,
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
  final String? notes;

  TimetableSlot({
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
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
    String? notes,
  }) {
    return TimetableSlot(
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      notes: notes ?? this.notes,
    );
  }
}
