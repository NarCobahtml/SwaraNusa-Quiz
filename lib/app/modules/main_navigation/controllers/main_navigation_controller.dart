import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  MainNavigationController({int initialIndex = 0}) {
    bottomNavIndex.value = initialIndex;
  }

  final bottomNavIndex = 0.obs;
  final pressedIndex = RxnInt();
  final isFabPressed = false.obs;

  void selectTab(int index) {
    bottomNavIndex.value = index;
  }

  void setPressedIndex(int? index) {
    pressedIndex.value = index;
  }

  void setFabPressed(bool value) {
    isFabPressed.value = value;
  }
}
