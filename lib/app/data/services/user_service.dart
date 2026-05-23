import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/backend_models.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';

/// Singleton service yang menyimpan data user yang sedang login.
/// Di-load sekali saat masuk ke MainNavigation, lalu di-share ke semua controller.
class UserService extends GetxService {
  UserService({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final isLoading = true.obs;

  static UserService get to => Get.find<UserService>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    isLoading.value = true;
    try {
      final uid = auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      currentUser.value = await _userRepository.currentUserProfile(uid);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => loadUser();

  void clear() {
    currentUser.value = null;
    isLoading.value = true;
  }
}
