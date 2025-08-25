import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'exam', 'assignment', 'event', 'class', 'holiday'
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? targetClass; // null for all classes
  final String? targetRole; // 'student', 'teacher', 'all'
  final String createdBy; // user ID
  final String createdByName;
  final String createdByRole;
  final DateTime createdAt;
  final bool isActive;
  final String? attachmentUrl; // for text-based resources
  final String? attachmentType; // 'text', 'link', 'document'
  final Map<String, dynamic>? metadata;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.targetClass,
    this.targetRole,
    required this.createdBy,
    required this.createdByName,
    required this.createdByRole,
    required this.createdAt,
    this.isActive = true,
    this.attachmentUrl,
    this.attachmentType,
    this.metadata,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'event',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'],
      endTime: map['endTime'],
      location: map['location'],
      targetClass: map['targetClass'],
      targetRole: map['targetRole'],
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdByRole: map['createdByRole'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      attachmentUrl: map['attachmentUrl'],
      attachmentType: map['attachmentType'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'targetClass': targetClass,
      'targetRole': targetRole,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByRole': createdByRole,
      'createdAt': createdAt,
      'isActive': isActive,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'metadata': metadata,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? location,
    String? targetClass,
    String? targetRole,
    String? createdBy,
    String? createdByName,
    String? createdByRole,
    DateTime? createdAt,
    bool? isActive,
    String? attachmentUrl,
    String? attachmentType,
    Map<String, dynamic>? metadata,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      targetClass: targetClass ?? this.targetClass,
      targetRole: targetRole ?? this.targetRole,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByRole: createdByRole ?? this.createdByRole,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      metadata: metadata ?? this.metadata,
    );
  }
}
