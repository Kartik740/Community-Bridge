// lib/screens/survey/form_fields/multiplechoice_field_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/survey_field_model.dart';

class MultichoiceFieldWidget extends StatefulWidget {
  final SurveyFieldModel field;
  final void Function(List<String> values) onChanged;
  final String? errorText;

  const MultichoiceFieldWidget({super.key, required this.field, required this.onChanged, this.errorText});

  @override
  State<MultichoiceFieldWidget> createState() => _MultichoiceFieldWidgetState();
}

class _MultichoiceFieldWidgetState extends State<MultichoiceFieldWidget> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(widget.field.label,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          if (widget.field.required)
            Text(' *', style: GoogleFonts.inter(color: AppColors.critical, fontWeight: FontWeight.w700)),
        ]),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(widget.errorText!, style: GoogleFonts.inter(color: AppColors.critical, fontSize: 12)),
        ],
        const SizedBox(height: 6),
        ...widget.field.options.map((opt) {
          final isSelected = _selected.contains(opt);
          return CheckboxListTile(
            value: isSelected,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: AppColors.primary,
            title: Text(opt[0].toUpperCase() + opt.substring(1),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
            onChanged: (v) {
              setState(() {
                if (v == true) _selected.add(opt);
                else _selected.remove(opt);
              });
              widget.onChanged(_selected.toList());
            },
          );
        }),
      ],
    );
  }
}
