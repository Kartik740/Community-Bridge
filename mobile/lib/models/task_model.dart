// lib/models/task_model.dart
// Represents an AI-generated task from the /tasks Firestore collection.

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String category; // food, medical, shelter, water, education
  final int urgencyScore; // 1–10
  final String status; // open, assigned, en_route, completed
  final String areaName;
  final int numberOfPeopleAffected;
  final String recommendedAction;
  final String reasoning;
  final String assignedVolunteerId;
  final String orgId;
  final String orgName;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.urgencyScore,
    required this.status,
    required this.areaName,
    required this.numberOfPeopleAffected,
    required this.recommendedAction,
    required this.reasoning,
    required this.assignedVolunteerId,
    required this.orgId,
    required this.orgName,
    this.lat,
    this.lng,
    this.createdAt,
    this.completedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: d['title'] ?? 'Task',
      category: d['category'] ?? 'general',
      urgencyScore: (d['urgencyScore'] as num?)?.toInt() ?? 5,
      status: d['status'] ?? 'open',
      areaName: d['areaName'] ?? '',
      numberOfPeopleAffected: (d['numberOfPeopleAffected'] as num?)?.toInt() ?? 0,
      recommendedAction: d['recommendedAction'] ?? '',
      reasoning: d['reasoning'] ?? '',
      assignedVolunteerId: d['assignedVolunteerId'] ?? '',
      orgId: d['orgId'] ?? '',
      orgName: d['orgName'] ?? '',
      lat: (d['location']?['lat'] as num?)?.toDouble(),
      lng: (d['location']?['lng'] as num?)?.toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Task',
      category: json['category'] ?? 'general',
      urgencyScore: (json['urgencyScore'] as num?)?.toInt() ?? 5,
      status: json['status'] ?? 'open',
      areaName: json['areaName'] ?? '',
      numberOfPeopleAffected:
          (json['numberOfPeopleAffected'] as num?)?.toInt() ?? 0,
      recommendedAction: json['recommendedAction'] ?? '',
      reasoning: json['reasoning'] ?? '',
      assignedVolunteerId: json['assignedVolunteerId'] ?? '',
      orgId: json['orgId'] ?? '',
      orgName: json['orgName'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'urgencyScore': urgencyScore,
        'status': status,
        'areaName': areaName,
        'numberOfPeopleAffected': numberOfPeopleAffected,
        'recommendedAction': recommendedAction,
        'reasoning': reasoning,
        'assignedVolunteerId': assignedVolunteerId,
        'orgId': orgId,
        'orgName': orgName,
        'lat': lat,
        'lng': lng,
      };

  TaskModel copyWith({String? status}) {
    return TaskModel(
      id: id,
      title: title,
      category: category,
      urgencyScore: urgencyScore,
      status: status ?? this.status,
      areaName: areaName,
      numberOfPeopleAffected: numberOfPeopleAffected,
      recommendedAction: recommendedAction,
      reasoning: reasoning,
      assignedVolunteerId: assignedVolunteerId,
      orgId: orgId,
      orgName: orgName,
      lat: lat,
      lng: lng,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}
