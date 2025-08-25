import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceModel {
  final String id;
  final String studentId;
  final String className;
  final String subject;
  final String examType; // 'midterm', 'final', 'assignment', 'quiz'
  final double marks;
  final double totalMarks;
  final String grade;
  final String? remarks;
  final String markedBy; // teacher ID
  final DateTime examDate;
  final DateTime markedAt;

  PerformanceModel({
    required this.id,
    required this.studentId,
    required this.className,
    required this.subject,
    required this.examType,
    required this.marks,
    required this.totalMarks,
    required this.grade,
    this.remarks,
    required this.markedBy,
    required this.examDate,
    required this.markedAt,
  });

  factory PerformanceModel.fromMap(Map<String, dynamic> map, String id) {
    return PerformanceModel(
      id: id,
      studentId: map['studentId'] ?? '',
      className: map['className'] ?? '',
      subject: map['subject'] ?? '',
      examType: map['examType'] ?? '',
      marks: (map['marks'] ?? 0).toDouble(),
      totalMarks: (map['totalMarks'] ?? 100).toDouble(),
      grade: map['grade'] ?? '',
      remarks: map['remarks'],
      markedBy: map['markedBy'] ?? '',
      examDate: (map['examDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      markedAt: (map['markedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'className': className,
      'subject': subject,
      'examType': examType,
      'marks': marks,
      'totalMarks': totalMarks,
      'grade': grade,
      'remarks': remarks,
      'markedBy': markedBy,
      'examDate': examDate,
      'markedAt': markedAt,
    };
  }

  double get percentage => (marks / totalMarks) * 100;

  PerformanceModel copyWith({
    String? id,
    String? studentId,
    String? className,
    String? subject,
    String? examType,
    double? marks,
    double? totalMarks,
    String? grade,
    String? remarks,
    String? markedBy,
    DateTime? examDate,
    DateTime? markedAt,
  }) {
    return PerformanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      marks: marks ?? this.marks,
      totalMarks: totalMarks ?? this.totalMarks,
      grade: grade ?? this.grade,
      remarks: remarks ?? this.remarks,
      markedBy: markedBy ?? this.markedBy,
      examDate: examDate ?? this.examDate,
      markedAt: markedAt ?? this.markedAt,
    );
  }
}
