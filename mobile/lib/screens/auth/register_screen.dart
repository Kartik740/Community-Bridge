// lib/screens/auth/register_screen.dart
// Multi-step registration form: Account Details → Volunteer Info → Choose NGO.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/validators.dart';
import '../../models/volunteer_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/skill_chip.dart';
import 'pending_approval_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VolunteerRequestModel? prefillData; // Used when re-applying after rejection
  const RegisterScreen({super.key, this.prefillData});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  // Step 1 controllers
  final _step1Key = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.prefillData?.name);
  late final _ageCtrl = TextEditingController(text: widget.prefillData?.age.toString() ?? '');
  late final _cityCtrl = TextEditingController(text: widget.prefillData?.city);
  late final _emailCtrl = TextEditingController(text: widget.prefillData?.email);
  late final _phoneCtrl = TextEditingController(text: widget.prefillData?.phone);
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;

  // Step 2 data
  List<String> _selectedSkills = [];
  String? _selectedAvailability;
  late final _motivationCtrl = TextEditingController(text: widget.prefillData?.motivation);

  // Step 3 data
  List<Map<String, dynamic>> _organisations = [];
  Map<String, dynamic>? _selectedOrg;
  bool _loadingOrgs = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedSkills = List.from(widget.prefillData?.skills ?? []);
    _selectedAvailability = widget.prefillData?.availabilityTime;
    _loadOrganisations();
  }

  Future<void> _loadOrganisations() async {
    final orgs = await FirebaseService.getAllOrganisations();
    if (mounted) {
      setState(() {
        _organisations = orgs;
        _loadingOrgs = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _cityCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _motivationCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_step1Key.currentState!.validate()) return;
    if (_currentStep == 1) {
      if (_selectedSkills.isEmpty) {
        _showError('Please select at least one skill.');
        return;
      }
      if (_selectedAvailability == null) {
        _showError('Please select your availability.');
        return;
      }
    }
    setState(() => _currentStep++);
  }

  Future<void> _submit() async {
    if (_selectedOrg == null) {
      _showError('Please select an NGO to apply to.');
      return;
    }

    setState(() => _submitting = true);

    final request = VolunteerRequestModel(
      id: '',
      volunteerId: '',
      name: _nameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      city: _cityCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      skills: _selectedSkills,
      availabilityTime: _selectedAvailability!,
      motivation: _motivationCtrl.text.trim().isEmpty
          ? null
          : _motivationCtrl.text.trim(),
      orgId: _selectedOrg!['id'],
      orgName: _selectedOrg!['name'] ?? 'NGO',
      status: 'pending',
    );

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(request, _passwordCtrl.text.trim());

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok) {
      _showError(auth.error ?? 'Registration failed. Please try again.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.critical),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply to Volunteer'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : const BackButton(),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: StepProgressIndicator(
              totalSteps: 3,
              currentStep: _currentStep + 1,
              size: 6,
              selectedColor: AppColors.primary,
              unselectedColor: AppColors.border,
              roundedEdges: const Radius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Step ${_currentStep + 1} of 3',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ['Account Details', 'Volunteer Details', 'Choose NGO'][_currentStep],
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(_currentStep),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1();
      case 1:
        return _step2();
      case 2:
        return _step3();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 1: Account Details ──────────────────────────────────────────────

  Widget _step1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Personal Information'),
            _field('Full Name', _nameCtrl,
                validator: Validators.name,
                hint: 'Your full name',
                icon: Icons.person_outline),
            _row([
              _field('Age', _ageCtrl,
                  validator: Validators.age,
                  hint: '25',
                  type: TextInputType.number,
                  icon: Icons.cake_outlined),
              _field('City', _cityCtrl,
                  validator: Validators.city,
                  hint: 'Bhopal',
                  icon: Icons.location_city_outlined),
            ]),
            _field('Email', _emailCtrl,
                validator: Validators.email,
                hint: 'you@example.com',
                type: TextInputType.emailAddress,
                icon: Icons.email_outlined),
            _field('Phone Number', _phoneCtrl,
                validator: Validators.phone,
                hint: '9876543210',
                type: TextInputType.phone,
                icon: Icons.phone_outlined),
            const SizedBox(height: AppSizes.sm),
            _sectionTitle('Set Password'),
            _passwordField(),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
              ),
              validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
            ),
            const SizedBox(height: AppSizes.xl),
            _nextButton(),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Volunteer Info ────────────────────────────────────────────────

  Widget _step2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Select Your Skills (choose at least 1)'),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppStrings.skillOptions.map((skill) {
              return SkillChip(
                skill: skill,
                selected: _selectedSkills.contains(skill),
                onTap: () => setState(() {
                  if (_selectedSkills.contains(skill)) {
                    _selectedSkills.remove(skill);
                  } else {
                    _selectedSkills.add(skill);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),
          _sectionTitle('Availability'),
          const SizedBox(height: AppSizes.sm),
          ...AppStrings.availabilityOptions.entries.map((entry) {
            return RadioListTile<String>(
              value: entry.key,
              groupValue: _selectedAvailability,
              onChanged: (v) => setState(() => _selectedAvailability = v),
              title: Text(entry.value,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textPrimary)),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }),
          const SizedBox(height: AppSizes.md),
          _sectionTitle('Motivation (optional)'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _motivationCtrl,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'Why do you want to volunteer?',
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _nextButton(),
        ],
      ),
    );
  }

  // ─── Step 3: Choose NGO ────────────────────────────────────────────────────

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            AppStrings.selectNGO,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: _loadingOrgs
              ? const Center(child: CircularProgressIndicator())
              : _organisations.isEmpty
                  ? Center(
                      child: Text(
                        'No NGOs found. Check your connection.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _organisations.length,
                      itemBuilder: (_, i) {
                        final org = _organisations[i];
                        final isSelected = _selectedOrg?['id'] == org['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedOrg = org),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.business_rounded,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        org['name'] ?? 'NGO',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      if (org['location'] != null)
                                        Text(
                                          org['location'],
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeightLg,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(AppStrings.submitApplication),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeightLg,
      child: ElevatedButton(
        onPressed: _nextStep,
        child: Text(_currentStep < 2 ? 'Next →' : AppStrings.submitApplication),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? Function(String?)? validator,
    String? hint,
    TextInputType? type,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _passwordCtrl,
        obscureText: _obscurePass,
        validator: Validators.password,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      children: children
          .map((w) => Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: w,
              )))
          .toList(),
    );
  }
}
