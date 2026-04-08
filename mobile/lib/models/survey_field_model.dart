// lib/models/survey_field_model.dart
// Represents a single field in a survey form schema.

class SurveyFieldModel {
  final String id;
  final String label;
  final String type; // text, number, dropdown, multiplechoice, date, photo
  final bool required;
  final List<String> options; // for dropdown and multiplechoice

  const SurveyFieldModel({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    this.options = const [],
  });

  factory SurveyFieldModel.fromJson(Map<String, dynamic> json) {
    return SurveyFieldModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'required': required,
      'options': options,
    };
  }
}
