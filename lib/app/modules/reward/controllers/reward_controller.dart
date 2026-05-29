import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/backend_models.dart';
import 'package:swaranusaquiz/app/data/providers/backend_bootstrap.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/modules/reward/models/reward_instrument.dart';
import 'package:swaranusaquiz/app/modules/reward/models/reward_mission.dart';
import 'package:swaranusaquiz/app/modules/reward/models/unlockable_instrument.dart';
import 'package:swaranusaquiz/app/utils/app_snackbar.dart';

class RewardController extends GetxController {
  RewardController({
    UserRepository? userRepository,
    ContentRepository? contentRepository,
  }) : _userRepository = userRepository ?? UserRepository(),
       _contentRepository = contentRepository ?? ContentRepository();

  final UserRepository _userRepository;
  final ContentRepository _contentRepository;
  UserService get _userService => UserService.to;

  final isClaimingDaily = false.obs;
  final dailyAlreadyClaimed = false.obs;
  final dailyRewardCoin = 100.obs;
  final isPurchasingInstrument = false.obs;
  final claimingMissionId = RxnString();
  final _instrumentDocs = <InstrumentDoc>[].obs;
  final _missionDocs = <MissionDoc>[].obs;
  final _missionProgressById = <String, MissionProgressDoc>{}.obs;

  int get coinBalance => _userService.currentUser.value?.coin ?? 0;

  @override
  void onInit() {
    super.onInit();
    _loadDailyLoginRewardState();
    _loadRewardInstruments();
    _loadMissions();
  }

  Future<void> _loadRewardInstruments() async {
    try {
      final docs = await _contentRepository.loadInstruments();
      final uid = auth.FirebaseAuth.instance.currentUser?.uid;
      final ownedIds = uid == null
          ? const <String>{}
          : await _contentRepository.loadOwnedInstrumentIds(uid);
      final instruments = docs
          .map((doc) => doc.copyWith(owned: ownedIds.contains(doc.id)))
          .toList(growable: false);
      _instrumentDocs.assignAll(instruments);
      BackendBootstrap.instance.instruments = instruments;
    } catch (_) {
      _instrumentDocs.clear();
    }
  }

  Future<void> _loadMissions() async {
    try {
      final docs = await _contentRepository.loadMissions();
      final uid = auth.FirebaseAuth.instance.currentUser?.uid;
      final progressById = uid == null
          ? const <String, MissionProgressDoc>{}
          : await _contentRepository.loadMissionProgress(uid);
      _missionDocs.assignAll(docs);
      _missionProgressById.assignAll(progressById);
      BackendBootstrap.instance.missions = docs;
    } catch (_) {
      _missionDocs.clear();
      _missionProgressById.clear();
    }
  }

  Future<void> _loadDailyLoginRewardState() async {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      await _loadDailyRewardCoin(1);
      return;
    }
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final snapshot = await _userRepository.getDailyLoginData(uid);
    var currentStreak = 0;
    if (snapshot != null) {
      dailyAlreadyClaimed.value =
          snapshot['lastLoginDate'] == today &&
          snapshot['claimedToday'] == true;
      currentStreak = (snapshot['currentStreak'] as num?)?.toInt() ?? 0;
    }

    await _loadDailyRewardCoin(currentStreak + 1);
  }

  Future<void> _loadDailyRewardCoin(int nextStreak) async {
    try {
      final rewardId = 'day_${((nextStreak - 1) % 7) + 1}';
      final reward = await _contentRepository.loadDailyLoginReward(rewardId);
      dailyRewardCoin.value = (reward?['rewardCoin'] as num?)?.toInt() ?? 100;
    } catch (_) {
      dailyRewardCoin.value = 100;
    }
  }

  Future<void> claimDailyLogin() async {
    if (isClaimingDaily.value || dailyAlreadyClaimed.value) return;
    isClaimingDaily.value = true;
    try {
      await RewardService.instance.claimDailyLogin();
      dailyAlreadyClaimed.value = true;

      await _userService.reload();
      await _loadDailyLoginRewardState();
      AppSnackbar.success(
        'Bonus Diklaim!',
        'Koin harianmu berhasil ditambahkan.',
      );
    } catch (e) {
      AppSnackbar.error('Gagal', 'Tidak dapat mengklaim bonus. Coba lagi.');
    } finally {
      isClaimingDaily.value = false;
    }
  }

  List<RewardInstrument> get instruments {
    final List<InstrumentDoc> backendInstruments = _instrumentDocs.isNotEmpty
        ? _instrumentDocs.toList(growable: false)
        : BackendBootstrap.instance.instruments;
    if (backendInstruments.isNotEmpty) {
      return backendInstruments
          .where((instrument) => instrument.price <= 0 || instrument.owned)
          .map(RewardInstrument.fromDoc)
          .toList(growable: false);
    }

    return const [
      RewardInstrument(
        id: 'sasando',
        imageSource: 'assets/image/Reward.png',
        name: 'Sasando',
        region: 'Nusa Tenggara Timur',
      ),
      RewardInstrument(
        id: 'gamelan',
        imageSource: 'assets/image/Reward.png',
        name: 'Gamelan',
        region: 'Jawa Tengah',
        noteSources: [
          'audio/n1.mp3',
          'audio/n2.mp3',
          'audio/n3.mp3',
          'audio/n4.mp3',
          'audio/n5.mp3',
          'audio/n6.mpeg',
        ],
        opensMinigame: true,
      ),
      RewardInstrument(
        id: 'kolintang',
        imageSource: 'assets/image/Reward.png',
        name: 'Kolintang',
        region: 'Sulawesi Utara',
      ),
    ];
  }

  List<RewardMission> get activeMissions {
    final missions = _missionDocs.isNotEmpty
        ? _missionDocs.toList(growable: false)
        : BackendBootstrap.instance.missions;
    return missions
        .map((mission) {
          final progress = _missionProgressById[mission.id];
          final target = progress?.target ?? mission.targetValue;
          final progressValue = progress?.progress ?? 0;
          final ratio = target <= 0 ? 0.0 : progressValue / target;
          return RewardMission(
            id: mission.id,
            title: mission.title,
            progress: ratio.clamp(0.0, 1.0).toDouble(),
            progressValue: progressValue,
            targetValue: target,
            rewardCoin: mission.rewardCoin,
            rewardXp: mission.rewardXp,
            isCompleted: progress?.isCompleted ?? false,
            isClaimed: progress?.isClaimed ?? false,
          );
        })
        .toList(growable: false);
  }

  UnlockableInstrument get unlockableInstrument {
    final List<InstrumentDoc> backendInstruments = _instrumentDocs.isNotEmpty
        ? _instrumentDocs.toList(growable: false)
        : BackendBootstrap.instance.instruments;
    for (final instrument in backendInstruments) {
      if (!instrument.owned && instrument.price > 0) {
        return UnlockableInstrument.fromDoc(instrument);
      }
    }

    return const UnlockableInstrument(
      id: 'angklung',
      imageSource: 'assets/image/Reward.png',
      name: 'Angklung',
      price: 5000,
    );
  }

  void openInstrument(RewardInstrument instrument) {
    if (!instrument.opensMinigame) return;
    Get.toNamed(
      AppRoutes.gamelanMinigame,
      arguments: {
        'instrumentId': instrument.id,
        'instrumentName': instrument.name,
        'noteSources': instrument.noteSources,
      },
    );
  }

  Future<void> purchaseUnlockableInstrument() async {
    final instrument = unlockableInstrument;
    if (instrument.id.isEmpty || isPurchasingInstrument.value) return;
    if (coinBalance < instrument.price) {
      AppSnackbar.error(
        'Koin tidak cukup',
        'Kumpulkan koin lagi untuk membeli instrumen ini.',
      );
      return;
    }

    isPurchasingInstrument.value = true;
    try {
      await RewardService.instance.purchaseInstrument(instrument.id);
      await _userService.reload();
      await _loadRewardInstruments();
      await _loadMissions();
      AppSnackbar.success(
        'Instrumen terbuka',
        '${instrument.name} berhasil ditambahkan.',
      );
    } catch (_) {
      AppSnackbar.error('Gagal', 'Tidak dapat membeli instrumen. Coba lagi.');
    } finally {
      isPurchasingInstrument.value = false;
    }
  }

  Future<void> claimMission(RewardMission mission) async {
    if (!mission.isCompleted ||
        mission.isClaimed ||
        claimingMissionId.value != null) {
      return;
    }

    claimingMissionId.value = mission.id;
    try {
      await MissionService.instance.claimMission(mission.id);
      await _userService.reload();
      await _loadMissions();
      await _loadRewardInstruments();
      AppSnackbar.success('Misi diklaim', 'Hadiah misi berhasil ditambahkan.');
    } catch (_) {
      AppSnackbar.error('Gagal', 'Tidak dapat mengklaim misi. Coba lagi.');
    } finally {
      claimingMissionId.value = null;
    }
  }
}
