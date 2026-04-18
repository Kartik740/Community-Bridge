// lib/screens/survey/form_fields/photo_field_widget.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/survey_field_model.dart';

class PhotoFieldWidget extends StatefulWidget {
  final SurveyFieldModel field;
  final void Function(String localPath) onChanged;
  final String? errorText;

  const PhotoFieldWidget({super.key, required this.field, required this.onChanged, this.errorText});

  @override
  State<PhotoFieldWidget> createState() => _PhotoFieldWidgetState();
}

class _PhotoFieldWidgetState extends State<PhotoFieldWidget> {
  File? _photo;
  final _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) {
      setState(() => _photo = File(img.path));
      try {
        final bytes = await img.readAsBytes();
        final base64String = 'data:image/jpeg;base64,' + base64Encode(bytes);
        widget.onChanged(base64String);
      } catch (e) {
        widget.onChanged(img.path); // Fallback if encoding fails
      }
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
          onTap: _pickPhoto,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null ? AppColors.critical : AppColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: _photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_photo!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 32, color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      Text('Tap to take photo',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 13)),
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
