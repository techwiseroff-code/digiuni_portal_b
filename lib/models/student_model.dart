import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String className;
  final String section;
  final String? profileImageUrl;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String address;
  final String parentName;
  final String parentPhone;
  final DateTime admissionDate;
  final bool isActive;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.className,
    required this.section,
    this.profileImageUrl,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.parentName,
    required this.parentPhone,
    required this.admissionDate,
    this.isActive = true,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      className: map['className'] ?? '',
      section: map['section'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      parentName: map['parentName'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      admissionDate:
          (map['admissionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'className': className,
      'section': section,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'address': address,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'admissionDate': admissionDate,
      'isActive': isActive,
    };
  }

  StudentModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? studentId,
    String? className,
    String? section,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? address,
    String? parentName,
    String? parentPhone,
    DateTime? admissionDate,
    bool? isActive,
  }) {
    return StudentModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      section: section ?? this.section,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      admissionDate: admissionDate ?? this.admissionDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
