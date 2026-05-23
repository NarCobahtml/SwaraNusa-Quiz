import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/modules/reward/models/reward_instrument.dart';
import 'package:swaranusaquiz/app/modules/reward/models/reward_mission.dart';
import 'package:swaranusaquiz/app/modules/reward/models/unlockable_instrument.dart';
import 'package:swaranusaquiz/app/utils/app_snackbar.dart';

class RewardController extends GetxController {
  RewardController({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;
  UserService get _userService => UserService.to;

  final isClaimingDaily = false.obs;
  final dailyAlreadyClaimed = false.obs;

  // Baca koin langsung dari UserService — reaktif otomatis
  int get coinBalance => _userService.currentUser.value?.coin ?? 0;

  @override
  void onInit() {
    super.onInit();
    _checkDailyClaimed();
  }

  Future<void> _checkDailyClaimed() async {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final snapshot = await _userRepository.getDailyLoginData(uid);
    if (snapshot != null) {
      dailyAlreadyClaimed.value =
          snapshot['lastLoginDate'] == today &&
          snapshot['claimedToday'] == true;
    }
  }

  Future<void> claimDailyLogin() async {
    if (isClaimingDaily.value || dailyAlreadyClaimed.value) return;
    isClaimingDaily.value = true;
    try {
      await RewardService.instance.claimDailyLogin();
      dailyAlreadyClaimed.value = true;
      // Reload UserService agar koin terupdate di semua halaman
      await _userService.reload();
      AppSnackbar.success(
        'Bonus Diklaim!',
        'Koin harianmu berhasil ditambahkan.',
      );
    } catch (e) {
      AppSnackbar.error(
        'Gagal',
        'Tidak dapat mengklaim bonus. Coba lagi.',
      );
    } finally {
      isClaimingDaily.value = false;
    }
  }

  List<RewardInstrument> get instruments {
    return const [
      RewardInstrument(
        imagePath: 'assets/image/gambar_angklung.png',
        name: 'Angklung',
        region: 'Jawa Barat',
      ),
      RewardInstrument(
        imagePath: 'assets/image/gambar_gamelan.png',
        name: 'Gamelan',
        region: 'Jawa Tengah',
        opensMinigame: true,
      ),
      RewardInstrument(
        imagePath: 'assets/image/gambar_kolintang.png',
        name: 'Kolintang',
        region: 'Sulawesi Utara',
      ),
    ];
  }

  List<RewardMission> get activeMissions {
    return const [
      RewardMission(
        title: 'Selesaikan 3 Kuis Tebak Suara',
        progress: 0.6,
        reward: 50,
      ),
      RewardMission(
        title: 'Identifikasi 5 Instrumen Bambu',
        progress: 0.2,
        reward: 75,
      ),
    ];
  }

  UnlockableInstrument get unlockableInstrument {
    return const UnlockableInstrument(
      imagePath: 'assets/image/gambar_sasando.png',
      name: 'Sasando',
      description: 'Buka alat musik khas Nusa Tenggara Timur',
      price: 5000,
    );
  }

  void openInstrument(RewardInstrument instrument) {
    if (!instrument.opensMinigame) return;
    Get.toNamed(AppRoutes.gamelanMinigame);
  }
}
