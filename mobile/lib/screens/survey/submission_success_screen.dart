// lib/screens/survey/submission_success_screen.dart
// Shown after a survey is submitted — two modes: synced (online) and saved_offline.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/sync_service.dart';
import '../../core/utils/connectivity_helper.dart';
import '../home/home_screen.dart';

class SubmissionSuccessScreen extends StatelessWidget {
  final String surveyTitle;
  final String orgName;
  final bool isOnline;

  const SubmissionSuccessScreen({
    super.key,
    required this.surveyTitle,
    required this.orgName,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.successLight : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Icon(
                    isOnline ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                    size: 60,
                    color: isOnline ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                isOnline ? 'Response Submitted!' : 'Response Saved Locally',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textH2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                isOnline
                    ? 'Your response has been sent to $orgName successfully.'
                    : 'No internet connection. Your response is saved on this device and will sync automatically when you come back online.',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textMd,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xxl),
              // Sync Now button (offline mode only)
              if (!isOnline) ...[
                FutureBuilder<bool>(
                  future: ConnectivityHelper.isOnline(),
                  builder: (ctx, snap) {
                    final canSync = snap.data == true;
                    return SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeightMd,
                      child: ElevatedButton.icon(
                        onPressed: canSync
                            ? () => context.read<SyncService>().attemptSync()
                            : null,
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        label: const Text('Sync Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.border,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSizes.sm),
              ],
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightMd,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fill Another Survey'),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (r) => false,
                ),
                child: Text(
                  'Go to Home',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
