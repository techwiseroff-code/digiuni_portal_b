import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String className;
  final String subject;
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final String? remarks;
  final String markedBy; // teacher ID
  final DateTime markedAt;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.className,
    required this.subject,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
    required this.markedAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      studentId: map['studentId'] ?? '',
      className: map['className'] ?? '',
      subject: map['subject'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'absent',
      remarks: map['remarks'],
      markedBy: map['markedBy'] ?? '',
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'className': className,
      'subject': subject,
      'date': date,
      'status': status,
      'remarks': remarks,
      'markedBy': markedBy,
      'markedAt': markedAt,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? className,
    String? subject,
    DateTime? date,
    String? status,
    String? remarks,
    String? markedBy,
    DateTime? markedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
    );
  }
}
