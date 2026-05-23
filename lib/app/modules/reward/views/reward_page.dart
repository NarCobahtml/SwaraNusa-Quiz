import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/reward/controllers/reward_controller.dart';
import 'package:swaranusaquiz/app/modules/reward/widgets/active_missions_section.dart';
import 'package:swaranusaquiz/app/modules/reward/widgets/coin_balance_badge.dart';
import 'package:swaranusaquiz/app/modules/reward/widgets/daily_login_bonus_card.dart';
import 'package:swaranusaquiz/app/modules/reward/widgets/instrument_collection_section.dart';
import 'package:swaranusaquiz/app/modules/reward/widgets/unlock_instrument_card.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardController>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: topPadding + 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => CoinBalanceBadge(balance: controller.coinBalance)),
                const SizedBox(height: 24),
                InstrumentCollectionSection(
                  instruments: controller.instruments,
                  onInstrumentTap: (instrument) {
                    controller.openInstrument(instrument);
                  },
                ),
                const SizedBox(height: 24),
                const DailyLoginBonusCard(),
                const SizedBox(height: 24),
                ActiveMissionsSection(missions: controller.activeMissions),
                const SizedBox(height: 24),
                UnlockInstrumentCard(
                  instrument: controller.unlockableInstrument,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
