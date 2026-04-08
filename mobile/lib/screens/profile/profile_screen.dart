// lib/screens/profile/profile_screen.dart
// Shows volunteer profile info, availability toggle, location update, sync, and logout.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/location_service.dart';
import '../../core/services/sync_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _updatingLocation = false;

  Future<void> _updateLocation() async {
    setState(() => _updatingLocation = true);
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() => _updatingLocation = false);

    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get location. Check GPS permissions.'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    await context
        .read<AuthProvider>()
        .updateLocation(pos.latitude, pos.longitude);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final volunteer = context.watch<AuthProvider>().volunteer;
    final sync = context.watch<SyncService>();

    if (volunteer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  volunteer.initials,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              volunteer.name,
              style: GoogleFonts.inter(
                fontSize: AppSizes.textH2,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                volunteer.orgName,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Info card
            _card([
              _infoRow(Icons.email_outlined, volunteer.email),
              const Divider(height: 12),
              _infoRow(Icons.phone_outlined, volunteer.phone),
              const Divider(height: 12),
              _infoRow(Icons.location_city_outlined, volunteer.city),
              const Divider(height: 12),
              _infoRow(
                  Icons.schedule_outlined,
                  _availabilityLabel(volunteer.availabilityTime)),
            ]),
            const SizedBox(height: AppSizes.md),

            // Skills
            _section(
              'Skills',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: volunteer.skills.map((skill) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      skill[0].toUpperCase() + skill.substring(1),
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Availability toggle
            _card([
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      volunteer.availability
                          ? 'Available for tasks'
                          : 'Not available',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: volunteer.availability,
                    activeColor: AppColors.success,
                    onChanged: (v) =>
                        context.read<AuthProvider>().setAvailability(v),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: AppSizes.md),

            // Update location
            _card([
              Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded,
                      size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Location',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        if (volunteer.lat != null)
                          Text(
                            '${volunteer.lat!.toStringAsFixed(4)}, ${volunteer.lng!.toStringAsFixed(4)}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _updatingLocation ? null : _updateLocation,
                    child: _updatingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Update'),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: AppSizes.md),

            // Sync
            _card([
              Row(
                children: [
                  const Icon(Icons.cloud_sync_rounded,
                      size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${sync.pendingCount} responses pending sync',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: sync.isSyncing ? null : () => sync.attemptSync(),
                    child: sync.isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sync Now'),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: AppSizes.xl),

            // Logout
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightMd,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.critical,
                  side: const BorderSide(color: AppColors.critical),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _section(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.sm),
          content,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  String _availabilityLabel(String key) {
    const labels = {
      'mornings': 'Mornings (6am – 12pm)',
      'evenings': 'Evenings (4pm – 9pm)',
      'weekends': 'Weekends Only',
      'fulltime': 'Full Time Available',
    };
    return labels[key] ?? key;
  }
}
