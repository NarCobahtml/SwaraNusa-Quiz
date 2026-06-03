import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/season_service.dart';
import 'package:swaranusaquiz/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SeasonService>()) {
      Get.put<SeasonService>(SeasonService(), permanent: true);
    }
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
