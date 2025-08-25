import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'announcement', 'attendance', 'grade', 'event', 'general'
  final String? targetUserId; // null for general notifications
  final String? targetRole; // 'student', 'teacher', 'all'
  final String? targetClass; // null for general notifications
  final String senderId;
  final String senderName;
  final String senderRole;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl; // optional link to related screen
  final Map<String, dynamic>? metadata; // additional data

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetUserId,
    this.targetRole,
    this.targetClass,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'general',
      targetUserId: map['targetUserId'],
      targetRole: map['targetRole'],
      targetClass: map['targetClass'],
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      actionUrl: map['actionUrl'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'targetUserId': targetUserId,
      'targetRole': targetRole,
      'targetClass': targetClass,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'createdAt': createdAt,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? targetUserId,
    String? targetRole,
    String? targetClass,
    String? senderId,
    String? senderName,
    String? senderRole,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRole: targetRole ?? this.targetRole,
      targetClass: targetClass ?? this.targetClass,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
