// lib/screens/survey/form_fields/date_field_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/survey_field_model.dart';

class DateFieldWidget extends StatefulWidget {
  final SurveyFieldModel field;
  final void Function(String value) onChanged;
  final String? errorText;

  const DateFieldWidget({super.key, required this.field, required this.onChanged, this.errorText});

  @override
  State<DateFieldWidget> createState() => _DateFieldWidgetState();
}

class _DateFieldWidgetState extends State<DateFieldWidget> {
  DateTime? _selected;
  final _fmt = DateFormat('d MMM yyyy');

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selected = picked);
      widget.onChanged(_fmt.format(picked));
    }
  }

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
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null ? AppColors.critical : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  _selected != null ? _fmt.format(_selected!) : 'Select date',
                  style: GoogleFonts.inter(
                    color: _selected != null ? AppColors.textPrimary : AppColors.textHint,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.errorText!,
                style: GoogleFonts.inter(color: AppColors.critical, fontSize: 12)),
          ),
      ],
    );
  }
}
