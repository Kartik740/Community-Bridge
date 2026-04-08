// lib/screens/auth/rejected_screen.dart
// Shown when a volunteer's application has been rejected.
// Allows re-applying to a different NGO with all previous details pre-filled.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class RejectedScreen extends StatelessWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.read<AuthProvider>().request;
    final reason = request?.rejectionReason ?? 'No reason provided.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rejection icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.criticalLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 56,
                  color: AppColors.critical,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                'Application Not Approved',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textH2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Your application was reviewed but could not be approved at this time.',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textMd,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              // Rejection reason
              if (reason.isNotEmpty) ...[
                const SizedBox(height: AppSizes.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.criticalLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.critical.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason from organiser:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.critical,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.textMd,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Re-apply button — goes to step 3 with pre-filled data
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(prefillData: request),
                      ),
                    );
                  },
                  child: const Text('Apply to a Different NGO'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
