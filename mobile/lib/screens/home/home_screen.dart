// lib/screens/home/home_screen.dart
// Main shell with bottom navigation: Survey, Tasks, Profile.
// Shows offline banner and sync status. Central survey code search.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../models/survey_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/survey_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/sync_status_card.dart';
import '../survey/survey_form_screen.dart';
import '../tasks/tasks_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _initTasks();
  }

  void _initConnectivity() async {
    _isOnline = await ConnectivityHelper.isOnline();
    ConnectivityHelper.onConnectivityChanged.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
    if (mounted) setState(() {});
  }

  void _initTasks() {
    final uid = context.read<AuthProvider>().volunteer?.id;
    if (uid != null) {
      context.read<TaskProvider>().startListening(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (!_isOnline) const OfflineBanner(),
          const SyncStatusCard(),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: const [
                _SurveyTab(),
                TasksScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Survey',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Survey Search Tab ──────────────────────────────────────────────────────

class _SurveyTab extends StatefulWidget {
  const _SurveyTab();

  @override
  State<_SurveyTab> createState() => _SurveyTabState();
}

class _SurveyTabState extends State<_SurveyTab> {
  final _codeCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a survey code')),
      );
      return;
    }

    setState(() => _isSearching = true);
    final provider = context.read<SurveyProvider>();
    final survey = await provider.searchByCode(code);
    if (!mounted) return;
    setState(() => _isSearching = false);

    if (survey != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SurveyFormScreen(
            survey: survey,
            isOfflineMode: provider.isOfflineMode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? AppStrings.surveyNotFound),
          backgroundColor: AppColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final volunteer = context.watch<AuthProvider>().volunteer;
    final recentSurveys = context.watch<SurveyProvider>().recentSurveys;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.sm),
            // Greeting
            Text(
              'Hello, ${volunteer?.name.split(' ').first ?? 'Volunteer'} 👋',
              style: GoogleFonts.inter(
                fontSize: AppSizes.textH3,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              volunteer?.orgName ?? 'CommunityBridge',
              style: GoogleFonts.inter(
                fontSize: AppSizes.textMd,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Search card
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.findSurvey,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.textXl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter the 6-character code from your NGO',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.textSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'XXXXXX',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 22,
                        letterSpacing: 6,
                        color: AppColors.textHint,
                      ),
                      counterText: '',
                    ),
                    maxLength: 8,
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightMd,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _search,
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(AppStrings.search),
                    ),
                  ),
                ],
              ),
            ),

            // Recently used
            if (recentSurveys.isNotEmpty) ...[
              const SizedBox(height: AppSizes.lg),
              Text(
                AppStrings.recentlySeen,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.textLg,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              ...recentSurveys.map((s) => _RecentSurveyCard(survey: s)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;

  const _RecentSurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    final model = SurveyModel.fromJson(survey);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                SurveyFormScreen(survey: model, isOfflineMode: true),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    model.surveyCode,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
