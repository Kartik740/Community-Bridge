// lib/models/volunteer_request_model.dart
// Represents a pending volunteer application in /volunteerRequests.

import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerRequestModel {
  final String id;
  final String volunteerId;
  final String name;
  final int age;
  final String city;
  final String email;
  final String phone;
  final List<String> skills;
  final String availabilityTime;
  final String? motivation;
  final String orgId;
  final String orgName;
  final String status; // "pending" | "approved" | "rejected"
  final String? rejectionReason;
  final DateTime? appliedAt;
  final DateTime? reviewedAt;

  const VolunteerRequestModel({
    required this.id,
    required this.volunteerId,
    required this.name,
    required this.age,
    required this.city,
    required this.email,
    required this.phone,
    required this.skills,
    required this.availabilityTime,
    this.motivation,
    required this.orgId,
    required this.orgName,
    required this.status,
    this.rejectionReason,
    this.appliedAt,
    this.reviewedAt,
  });

  factory VolunteerRequestModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VolunteerRequestModel(
      id: doc.id,
      volunteerId: d['volunteerId'] ?? doc.id,
      name: d['name'] ?? '',
      age: (d['age'] as num?)?.toInt() ?? 0,
      city: d['city'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      skills: List<String>.from(d['skills'] ?? []),
      availabilityTime: d['availabilityTime'] ?? '',
      motivation: d['motivation'],
      orgId: d['orgId'] ?? '',
      orgName: d['orgName'] ?? '',
      status: d['status'] ?? 'pending',
      rejectionReason: d['rejectionReason'],
      appliedAt: (d['appliedAt'] as Timestamp?)?.toDate(),
      reviewedAt: (d['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory VolunteerRequestModel.fromJson(Map<String, dynamic> json) {
    return VolunteerRequestModel(
      id: json['id'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      name: json['name'] ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      city: json['city'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      availabilityTime: json['availabilityTime'] ?? '',
      motivation: json['motivation'],
      orgId: json['orgId'] ?? '',
      orgName: json['orgName'] ?? '',
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'name': name,
      'age': age,
      'city': city,
      'email': email,
      'phone': phone,
      'skills': skills,
      'availabilityTime': availabilityTime,
      'motivation': motivation,
      'orgId': orgId,
      'orgName': orgName,
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'volunteerId': volunteerId,
      'name': name,
      'age': age,
      'city': city,
      'email': email,
      'phone': phone,
      'skills': skills,
      'availabilityTime': availabilityTime,
      'motivation': motivation,
      'orgId': orgId,
      'orgName': orgName,
      'status': 'pending',
      'rejectionReason': null,
      'appliedAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
    };
  }
}
