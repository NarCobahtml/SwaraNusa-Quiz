import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/minigame/controllers/gamelan_minigame_controller.dart';
import 'package:swaranusaquiz/app/modules/minigame/widgets/gamelan_background.dart';
import 'package:swaranusaquiz/app/modules/minigame/widgets/gamelan_board.dart';
import 'package:swaranusaquiz/app/modules/minigame/widgets/gamelan_header.dart';

class GamelanMinigamePage extends StatelessWidget {
  const GamelanMinigamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GamelanMinigameController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const GamelanBackground(),
          SafeArea(
            child: Column(
              children: [
                const GamelanHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Obx(
                        () {
                          return GamelanBoard(
                            noteCount: controller.noteCount,
                            activePotIndex: controller.activePotIndex.value,
                            onPotPressed: controller.playNote,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
