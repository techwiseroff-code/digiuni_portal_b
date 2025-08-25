import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String uid;
  final String name;
  final String email;
  final String teacherId;
  final String department;
  final String qualification;
  final String? profileImageUrl;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String address;
  final DateTime joiningDate;
  final List<String> assignedClasses;
  final List<String> subjects;
  final bool isActive;

  TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.teacherId,
    required this.department,
    required this.qualification,
    this.profileImageUrl,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.joiningDate,
    required this.assignedClasses,
    required this.subjects,
    this.isActive = true,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map, String uid) {
    return TeacherModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      teacherId: map['teacherId'] ?? '',
      department: map['department'] ?? '',
      qualification: map['qualification'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      joiningDate:
          (map['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedClasses: List<String>.from(map['assignedClasses'] ?? []),
      subjects: List<String>.from(map['subjects'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'teacherId': teacherId,
      'department': department,
      'qualification': qualification,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'address': address,
      'joiningDate': joiningDate,
      'assignedClasses': assignedClasses,
      'subjects': subjects,
      'isActive': isActive,
    };
  }

  TeacherModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? teacherId,
    String? department,
    String? qualification,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? address,
    DateTime? joiningDate,
    List<String>? assignedClasses,
    List<String>? subjects,
    bool? isActive,
  }) {
    return TeacherModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      teacherId: teacherId ?? this.teacherId,
      department: department ?? this.department,
      qualification: qualification ?? this.qualification,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      joiningDate: joiningDate ?? this.joiningDate,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      subjects: subjects ?? this.subjects,
      isActive: isActive ?? this.isActive,
    );
  }
}
