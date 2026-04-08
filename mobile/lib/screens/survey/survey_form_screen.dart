// lib/screens/survey/survey_form_screen.dart
// Dynamic form renderer that builds fields based on the survey schema.
// Captures GPS silently on open, supports online direct submit and offline save.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/location_service.dart';
import '../../models/response_model.dart';
import '../../models/survey_field_model.dart';
import '../../models/survey_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/response_provider.dart';
import 'form_fields/date_field_widget.dart';
import 'form_fields/dropdown_field_widget.dart';
import 'form_fields/multiplechoice_field_widget.dart';
import 'form_fields/photo_field_widget.dart';
import 'form_fields/text_field_widget.dart';
import 'submission_success_screen.dart';

class SurveyFormScreen extends StatefulWidget {
  final SurveyModel survey;
  final bool isOfflineMode;

  const SurveyFormScreen({
    super.key,
    required this.survey,
    this.isOfflineMode = false,
  });

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final Map<String, dynamic> _answers = {};
  final Map<String, String?> _errors = {};
  final _scrollCtrl = ScrollController();

  Position? _position;
  bool _locationLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (mounted) setState(() {
      _position = pos;
      _locationLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─── Validation ────────────────────────────────────────────────────────────

  bool _validate() {
    bool valid = true;
    for (final field in widget.survey.fields) {
      if (field.required) {
        final val = _answers[field.id];
        bool empty = val == null ||
            (val is String && val.trim().isEmpty) ||
            (val is List && val.isEmpty);
        if (empty) {
          _errors[field.id] = '${field.label} is required';
          valid = false;
        } else {
          _errors[field.id] = null;
        }
      }
    }
    setState(() {});
    return valid;
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_validate()) {
      // Scroll to first error
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final volunteer = context.read<AuthProvider>().volunteer;
    if (volunteer == null) return;

    final response = ResponseModel(
      surveyId: widget.survey.id,
      orgId: widget.survey.orgId,
      volunteerId: volunteer.id,
      answers: _answers.entries
          .map((e) => {'fieldId': e.key, 'value': e.value})
          .toList(),
      lat: _position?.latitude,
      lng: _position?.longitude,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    final provider = context.read<ResponseProvider>();
    final ok = await provider.submit(response);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Submission failed'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SubmissionSuccessScreen(
          surveyTitle: widget.survey.title,
          orgName: volunteer.orgName,
          isOnline: provider.state == SubmitState.success,
        ),
      ),
    );
  }

  // ─── Dynamic Field Renderer ────────────────────────────────────────────────

  Widget _buildField(SurveyFieldModel field) {
    final error = _errors[field.id];

    Widget widget;
    switch (field.type) {
      case 'number':
        widget = TextFieldWidget(
          field: field,
          errorText: error,
          onChanged: (v) {
            _answers[field.id] = v;
            if (_errors[field.id] != null) setState(() => _errors[field.id] = null);
          },
        );
        break;
      case 'dropdown':
        widget = DropdownFieldWidget(
          field: field,
          errorText: error,
          onChanged: (v) {
            _answers[field.id] = v;
            if (_errors[field.id] != null) setState(() => _errors[field.id] = null);
          },
        );
        break;
      case 'multiplechoice':
        widget = MultichoiceFieldWidget(
          field: field,
          errorText: error,
          onChanged: (v) {
            _answers[field.id] = v;
            if (_errors[field.id] != null) setState(() => _errors[field.id] = null);
          },
        );
        break;
      case 'date':
        widget = DateFieldWidget(
          field: field,
          errorText: error,
          onChanged: (v) {
            _answers[field.id] = v;
            if (_errors[field.id] != null) setState(() => _errors[field.id] = null);
          },
        );
        break;
      case 'photo':
        widget = PhotoFieldWidget(
          field: field,
          errorText: error,
          onChanged: (v) {
            _answers[field.id] = v;
            if (_errors[field.id] != null) setState(() => _errors[field.id] = null);
          },
        );
        break;
      default:
        widget = TextFieldWidget(
          field: field,
          errorText: error,
          onChanged: (v) {
            _answers[field.id] = v;
            if (_errors[field.id] != null) setState(() => _errors[field.id] = null);
          },
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.survey.title, overflow: TextOverflow.ellipsis),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isOfflineMode
                  ? AppColors.warningLight
                  : AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.isOfflineMode ? '⚡ Offline' : '● Online',
              style: GoogleFonts.inter(
                color: widget.isOfflineMode ? AppColors.warning : AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // GPS status bar
          _buildLocationBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Survey description
                  if (widget.survey.description.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.survey.description,
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                  // Dynamic fields
                  ...widget.survey.fields.map(_buildField),
                  const SizedBox(height: AppSizes.xl),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit Survey'),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _locationLoading
          ? AppColors.warningLight
          : _position != null
              ? AppColors.successLight
              : AppColors.criticalLight,
      child: Row(
        children: [
          Icon(
            _locationLoading
                ? Icons.gps_not_fixed
                : _position != null
                    ? Icons.gps_fixed
                    : Icons.gps_off,
            size: 16,
            color: _locationLoading
                ? AppColors.warning
                : _position != null
                    ? AppColors.success
                    : AppColors.critical,
          ),
          const SizedBox(width: 8),
          Text(
            _locationLoading
                ? 'Capturing location...'
                : _position != null
                    ? 'Location captured ✓'
                    : 'Location unavailable',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _locationLoading
                  ? AppColors.warning
                  : _position != null
                      ? AppColors.success
                      : AppColors.critical,
            ),
          ),
        ],
      ),
    );
  }
}
