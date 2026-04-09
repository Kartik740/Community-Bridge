// lib/screens/survey/form_fields/dropdown_field_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/survey_field_model.dart';

class DropdownFieldWidget extends StatefulWidget {
  final SurveyFieldModel field;
  final void Function(String value) onChanged;
  final String? errorText;

  const DropdownFieldWidget({super.key, required this.field, required this.onChanged, this.errorText});

  @override
  State<DropdownFieldWidget> createState() => _DropdownFieldWidgetState();
}

class _DropdownFieldWidgetState extends State<DropdownFieldWidget> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.field.label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            if (widget.field.required)
              Text(' *', style: GoogleFonts.inter(color: AppColors.critical, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selected,
          decoration: InputDecoration(errorText: widget.errorText),
          hint: Text('Select ${widget.field.label.toLowerCase()}',
              style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14)),
          items: widget.field.options
              .map((opt) => DropdownMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt[0].toUpperCase() + opt.substring(1),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() => _selected = val);
            if (val != null) widget.onChanged(val);
          },
        ),
      ],
    );
  }
}
