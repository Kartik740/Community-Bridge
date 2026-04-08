// lib/models/survey_model.dart
// Represents a survey document from the /surveys Firestore collection.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'survey_field_model.dart';

class SurveyModel {
  final String id;
  final String title;
  final String description;
  final String surveyCode;
  final String orgId;
  final String? orgName;
  final List<SurveyFieldModel> fields;
  final bool isActive;
  final DateTime? createdAt;

  const SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.surveyCode,
    required this.orgId,
    this.orgName,
    required this.fields,
    required this.isActive,
    this.createdAt,
  });

  factory SurveyModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SurveyModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      surveyCode: d['surveyCode'] ?? '',
      orgId: d['orgId'] ?? '',
      orgName: d['orgName'],
      fields: (d['fields'] as List<dynamic>? ?? [])
          .map((f) => SurveyFieldModel.fromJson(Map<String, dynamic>.from(f as Map)))
          .toList(),
      isActive: d['isActive'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      surveyCode: json['surveyCode'] ?? '',
      orgId: json['orgId'] ?? '',
      orgName: json['orgName'],
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((f) => SurveyFieldModel.fromJson(Map<String, dynamic>.from(f as Map)))
          .toList(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'surveyCode': surveyCode,
      'orgId': orgId,
      'orgName': orgName,
      'fields': fields.map((f) => f.toJson()).toList(),
      'isActive': isActive,
    };
  }
}
