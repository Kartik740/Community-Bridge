// lib/screens/tasks/tasks_screen.dart
// Shows AI-assigned tasks for the current volunteer in real-time.
// Supports filter chips: All, Open, Assigned, Completed.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/urgency_badge.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Tasks')),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.loading) return const LoadingSkeleton();

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.critical, size: 48),
                  const SizedBox(height: 12),
                  Text(provider.error!,
                      style: GoogleFonts.inter(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter chips
              _FilterBar(
                selected: provider.filterStatus,
                onSelect: (s) => provider.setFilter(s),
              ),
              Expanded(
                child: provider.tasks.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: provider.tasks.length,
                        itemBuilder: (_, i) =>
                            _TaskCard(task: provider.tasks[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Filter Bar ─────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String? selected;
  final void Function(String?) onSelect;

  const _FilterBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final filters = {
      null: 'All',
      'open': 'Open',
      'assigned': 'Assigned',
      'en_route': 'En Route',
      'completed': 'Completed',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: filters.entries.map((entry) {
          final isActive = selected == entry.key;
          return GestureDetector(
            onTap: () => onSelect(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                entry.value,
                style: GoogleFonts.inter(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Task Card ───────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _categoryIcon(task.category),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                UrgencyBadge(score: task.urgencyScore),
                const SizedBox(width: 8),
                _statusChip(task.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.areaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${task.numberOfPeopleAffected} affected',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            if (task.recommendedAction.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.recommendedAction,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    final icons = {
      'food': Icons.restaurant_rounded,
      'medical': Icons.medical_services_rounded,
      'shelter': Icons.home_rounded,
      'water': Icons.water_drop_rounded,
      'education': Icons.school_rounded,
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icons[category.toLowerCase()] ?? Icons.task_alt_rounded,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }

  Widget _statusChip(String status) {
    final colors = {
      'open': (AppColors.surfaceVariant, AppColors.textSecondary),
      'assigned': (AppColors.primaryLight, AppColors.primary),
      'en_route': (AppColors.warningLight, AppColors.warning),
      'completed': (AppColors.successLight, AppColors.success),
    };
    final (bg, fg) = colors[status] ?? (AppColors.surfaceVariant, AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: GoogleFonts.inter(color: fg, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined,
                  size: 52, color: AppColors.textHint),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'No tasks assigned yet',
              style: GoogleFonts.inter(
                fontSize: AppSizes.textXl,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'The NGO will assign tasks based on community needs and your skills.',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.textMd, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
