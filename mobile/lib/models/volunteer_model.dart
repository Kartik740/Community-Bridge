// lib/models/volunteer_model.dart
// Represents an approved volunteer in the /volunteers collection.

import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerModel {
  final String id;
  final String name;
  final int age;
  final String city;
  final String email;
  final String phone;
  final String orgId;
  final String orgName;
  final List<String> skills;
  final String availabilityTime;
  final bool availability;
  final double? lat;
  final double? lng;
  final String? fcmToken;
  final DateTime? createdAt;

  const VolunteerModel({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.email,
    required this.phone,
    required this.orgId,
    required this.orgName,
    required this.skills,
    required this.availabilityTime,
    required this.availability,
    this.lat,
    this.lng,
    this.fcmToken,
    this.createdAt,
  });

  /// Creates a VolunteerModel from a Firestore DocumentSnapshot.
  factory VolunteerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VolunteerModel(
      id: doc.id,
      name: d['name'] ?? '',
      age: (d['age'] as num?)?.toInt() ?? 0,
      city: d['city'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      orgId: d['orgId'] ?? '',
      orgName: d['orgName'] ?? '',
      skills: List<String>.from(d['skills'] ?? []),
      availabilityTime: d['availabilityTime'] ?? '',
      availability: d['availability'] ?? true,
      lat: (d['location']?['lat'] as num?)?.toDouble(),
      lng: (d['location']?['lng'] as num?)?.toDouble(),
      fcmToken: d['fcmToken'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a VolunteerModel from a plain Map (e.g. from Hive cache).
  factory VolunteerModel.fromJson(Map<String, dynamic> json) {
    return VolunteerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      city: json['city'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      orgId: json['orgId'] ?? '',
      orgName: json['orgName'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      availabilityTime: json['availabilityTime'] ?? '',
      availability: json['availability'] ?? true,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      fcmToken: json['fcmToken'],
    );
  }

  /// Returns initials from name (e.g. "John Doe" → "JD").
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'city': city,
      'email': email,
      'phone': phone,
      'orgId': orgId,
      'orgName': orgName,
      'skills': skills,
      'availabilityTime': availabilityTime,
      'availability': availability,
      'lat': lat,
      'lng': lng,
      'fcmToken': fcmToken,
    };
  }

  VolunteerModel copyWith({
    bool? availability,
    double? lat,
    double? lng,
    String? fcmToken,
  }) {
    return VolunteerModel(
      id: id,
      name: name,
      age: age,
      city: city,
      email: email,
      phone: phone,
      orgId: orgId,
      orgName: orgName,
      skills: skills,
      availabilityTime: availabilityTime,
      availability: availability ?? this.availability,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
