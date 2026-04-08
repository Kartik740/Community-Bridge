// lib/widgets/urgency_badge.dart
// Coloured chip showing urgency score with appropriate colour coding.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class UrgencyBadge extends StatelessWidget {
  final int score;
  final bool large;

  const UrgencyBadge({super.key, required this.score, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.urgencyColor(score);
    final bg = AppColors.urgencyBgColor(score);
    final label = _label(score);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(large ? 10 : 6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: large ? 8 : 6,
            height: large ? 8 : 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: large ? 6 : 4),
          Text(
            large ? 'Urgency $score/10 · $label' : '$score · $label',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: large ? 13 : 11,
            ),
          ),
        ],
      ),
    );
  }

  String _label(int s) {
    if (s <= 3) return 'Low';
    if (s <= 6) return 'Medium';
    if (s <= 8) return 'High';
    return 'Critical';
  }
}
