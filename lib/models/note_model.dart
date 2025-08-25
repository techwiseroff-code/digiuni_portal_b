import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String studentId;
  final String title;
  final String content;
  final String? subject;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isImportant;
  final String? color; // hex color for UI

  NoteModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.content,
    this.subject,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isImportant = false,
    this.color,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      studentId: map['studentId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      subject: map['subject'],
      tags: map['tags'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isImportant: map['isImportant'] ?? false,
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'title': title,
      'content': content,
      'subject': subject,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isImportant': isImportant,
      'color': color,
    };
  }

  NoteModel copyWith({
    String? id,
    String? studentId,
    String? title,
    String? content,
    String? subject,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isImportant,
    String? color,
  }) {
    return NoteModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isImportant: isImportant ?? this.isImportant,
      color: color ?? this.color,
    );
  }
}
