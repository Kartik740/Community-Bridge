// lib/models/response_model.dart
// Represents a completed survey response, stored in Firestore or Hive.

class ResponseModel {
  final String? id; // null when pending sync
  final String surveyId;
  final String orgId;
  final String volunteerId;
  final List<Map<String, dynamic>> answers;
  final double? lat;
  final double? lng;
  final String status; // "pending" | "pending_sync" | "approved" | "analysed"
  final DateTime submittedAt;
  final DateTime? syncedAt;

  const ResponseModel({
    this.id,
    required this.surveyId,
    required this.orgId,
    required this.volunteerId,
    required this.answers,
    this.lat,
    this.lng,
    required this.status,
    required this.submittedAt,
    this.syncedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'surveyId': surveyId,
      'orgId': orgId,
      'volunteerId': volunteerId,
      'answers': answers,
      'location': lat != null && lng != null
          ? {'lat': lat, 'lng': lng}
          : null,
      'status': 'pending',
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  /// Used when saving to Hive for offline storage.
  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId,
      'orgId': orgId,
      'volunteerId': volunteerId,
      'answers': answers,
      'location': lat != null && lng != null
          ? {'lat': lat, 'lng': lng}
          : null,
      'status': 'pending',
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      id: json['id'],
      surveyId: json['surveyId'] ?? '',
      orgId: json['orgId'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      answers: List<Map<String, dynamic>>.from(
        (json['answers'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      lat: (json['location']?['lat'] as num?)?.toDouble(),
      lng: (json['location']?['lng'] as num?)?.toDouble(),
      status: json['status'] ?? 'pending',
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
