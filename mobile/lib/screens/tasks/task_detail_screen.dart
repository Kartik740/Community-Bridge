// lib/screens/tasks/task_detail_screen.dart
// Full detail view with map, recommended action, status buttons, and directions.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/urgency_badge.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _task;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final ok = await context.read<TaskProvider>().updateStatus(_task.id, newStatus);
    if (!mounted) return;
    setState(() {
      _isUpdating = false;
      if (ok) _task = _task.copyWith(status: newStatus);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Status updated!' : 'Update failed. Try again.'),
        backgroundColor: ok ? AppColors.success : AppColors.critical,
      ),
    );
  }

  Future<void> _openMaps() async {
    if (_task.lat == null || _task.lng == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_task.lat},${_task.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Complete?'),
        content: const Text(
            'Are you sure you want to mark this task as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) _updateStatus('completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Task Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _task.title,
              style: GoogleFonts.inter(
                fontSize: AppSizes.textH2,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                UrgencyBadge(score: _task.urgencyScore, large: true),
                const SizedBox(width: 8),
                _categoryBadge(_task.category),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Info rows
            _infoCard([
              _infoRow(Icons.place_outlined, 'Area', _task.areaName),
              _infoRow(Icons.category_outlined, 'Category',
                  _task.category[0].toUpperCase() + _task.category.substring(1)),
              _infoRow(Icons.people_outline, 'People Affected',
                  '${_task.numberOfPeopleAffected} people'),
              _infoRow(Icons.speed_rounded, 'Urgency Score',
                  '${_task.urgencyScore}/10'),
              _infoRow(
                  Icons.circle_outlined, 'Status', _task.status.replaceAll('_', ' ')),
            ]),
            const SizedBox(height: AppSizes.md),

            // What to do section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border(
                    left: BorderSide(color: AppColors.primary, width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What To Do',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _task.recommendedAction,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  if (_task.reasoning.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _task.reasoning,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Map
            if (_task.lat != null && _task.lng != null) ...[
              Text(
                'Location',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_task.lat!, _task.lng!),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('task'),
                        position: LatLng(_task.lat!, _task.lng!),
                        infoWindow: InfoWindow(title: _task.areaName),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    liteModeEnabled: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openMaps,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Get Directions'),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Assignment details
            _infoCard([
              _infoRow(Icons.business_rounded, 'Assigned by', _task.orgName),
              _infoRow(Icons.calendar_today_outlined, 'Created',
                  DateFormatter.shortDate(_task.createdAt)),
              if (_task.completedAt != null)
                _infoRow(Icons.check_circle_outlined, 'Completed',
                    DateFormatter.shortDate(_task.completedAt)),
            ]),
            const SizedBox(height: AppSizes.xl),

            // Action buttons
            _buildActionButtons(),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isUpdating) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_task.status) {
      case 'assigned':
        return SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeightLg,
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus('en_route'),
            icon: const Icon(Icons.directions_car_rounded),
            label: const Text('On My Way'),
          ),
        );
      case 'en_route':
        return SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeightLg,
          child: ElevatedButton.icon(
            onPressed: _confirmComplete,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
          ),
        );
      case 'completed':
        return Container(
          width: double.infinity,
          height: AppSizes.buttonHeightMd,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Task Completed',
                style: GoogleFonts.inter(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: r,
                ))
            .toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category[0].toUpperCase() + category.substring(1),
        style: GoogleFonts.inter(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
