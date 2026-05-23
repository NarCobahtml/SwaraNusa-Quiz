import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';

class SplashController extends GetxController {
  void openNextScreen() {
    final route = FirebaseAuth.instance.currentUser == null
        ? AppRoutes.login
        : AppRoutes.mainNavigation;
    Get.offNamed(route);
  }
}
