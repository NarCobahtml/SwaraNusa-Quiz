import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/reward/controllers/reward_controller.dart';

class RewardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RewardController>(() => RewardController());
  }
}
