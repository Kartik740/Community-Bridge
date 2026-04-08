// lib/screens/auth/pending_approval_screen.dart
// Shown after registration while awaiting NGO organiser approval.
// Listens to /volunteerRequests in real-time and auto-navigates on approval.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'rejected_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  late final Stream<DocumentSnapshot> _stream;
  String _orgName = '';

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    _orgName = context.read<AuthProvider>().request?.orgName ?? 'the NGO';

    _stream = FirebaseService.streamVolunteerRequest(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final status = data['status'] as String?;

            // Auto-navigate when status changes
            if (status == 'approved') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<AuthProvider>().refreshProfile().then((_) {
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  });
                }
              });
            } else if (status == 'rejected') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RejectedScreen()),
                  );
                }
              });
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pending_actions_rounded,
                      size: 56,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Text(
                    'Application Submitted!',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.textH2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Your application to $_orgName is under review. You will be notified once the organiser approves your request.',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.textMd,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  // Pulse indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.warning),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Waiting for approval...',
                        style: GoogleFonts.inter(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
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
          );
        },
      ),
    );
  }
}
