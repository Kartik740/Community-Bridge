// lib/screens/survey/form_fields/text_field_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/survey_field_model.dart';

class TextFieldWidget extends StatefulWidget {
  final SurveyFieldModel field;
  final void Function(String value) onChanged;
  final String? errorText;

  const TextFieldWidget({super.key, required this.field, required this.onChanged, this.errorText});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: widget.field.label, required: widget.field.required),
        const SizedBox(height: 6),
        TextFormField(
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.field.label.toLowerCase()}',
            errorText: widget.errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.critical),
            ),
          ),
        ),
      ],
    );
  }
}

// lib/screens/survey/form_fields/number_field_widget.dart
class NumberFieldWidget extends StatelessWidget {
  final SurveyFieldModel field;
  final void Function(String value) onChanged;
  final String? errorText;

  const NumberFieldWidget({super.key, required this.field, required this.onChanged, this.errorText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: field.label, required: field.required),
        const SizedBox(height: 6),
        TextFormField(
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0',
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

/// Shared label widget with red asterisk for required fields.
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        if (required)
          Text(' *',
              style: GoogleFonts.inter(color: AppColors.critical, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
