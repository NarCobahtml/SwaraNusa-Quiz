import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/profile/models/profile_data.dart';

class ProfileStatsSection extends StatelessWidget {
  final ProfileData profile;

  const ProfileStatsSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatCard(
              value: profile.quizCompleted.toString(),
              label: 'Kuis\nDiselesaikan',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              value: '${profile.correctAnswerPercentage}%',
              label: 'Jawaban\nBenar',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              value: profile.badgesEarned.toString(),
              label: 'Lencana\nDidapatkan',
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
