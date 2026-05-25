import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_header.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_list.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_podium.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/widgets/leaderboard_tab_bar.dart';

class LeaderboardScreen extends StatelessWidget {
  final String? currentUserId;
  final bool showNavbar;

  const LeaderboardScreen({
    super.key,
    this.currentUserId,
    this.showNavbar = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCurrentUserId =
        currentUserId ?? auth.FirebaseAuth.instance.currentUser?.uid;
    final controller = Get.isRegistered<LeaderboardController>()
        ? Get.find<LeaderboardController>()
        : Get.put(LeaderboardController());
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(
      () => Column(
        children: [
          SizedBox(height: topPadding + 16),
          const LeaderboardHeader(),
          const SizedBox(height: 20),
          const LeaderboardTabBar(),
          const SizedBox(height: 24),
          if (controller.isLoading.value)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (controller.errorMessage.value != null)
            Expanded(
              child: _LeaderboardStatus(
                message: controller.errorMessage.value!,
                onRetry: controller.watchLeaderboard,
              ),
            )
          else if (controller.users.isEmpty)
            const Expanded(
              child: _LeaderboardStatus(
                message: 'Belum ada data leaderboard.',
              ),
            )
          else ...[
            LeaderboardPodium(
              users: controller.topUsers,
              currentUserId: effectiveCurrentUserId,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LeaderboardList(
                users: controller.remainingUsers,
                currentUserId: effectiveCurrentUserId,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardStatus extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _LeaderboardStatus({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
