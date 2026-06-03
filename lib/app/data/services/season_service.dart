import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/providers/firestore_paths.dart';

class SeasonService extends GetxService {
  SeasonService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const fallbackSeasonId = 'season_default';

  final FirebaseFirestore _firestore;
  final activeSeasonId = fallbackSeasonId.obs;
  final activeSeasonTitle = 'Season Utama'.obs;
  final seasonDurationDays = 30.obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  Completer<void>? _firstLoadCompleter;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  static SeasonService get to => Get.find<SeasonService>();

  @override
  void onInit() {
    super.onInit();
    watchActiveSeason();
  }

  void watchActiveSeason() {
    _subscription?.cancel();
    isLoading.value = true;
    _firstLoadCompleter = Completer<void>();
    _subscription = _firestore.doc(FirestorePaths.seasonConfig).snapshots().listen(
      (snapshot) {
        final data = snapshot.data() ?? const <String, dynamic>{};
        errorMessage.value = null;
        activeSeasonId.value = _stringValue(data['activeSeasonId']).isNotEmpty
            ? _stringValue(data['activeSeasonId'])
            : fallbackSeasonId;
        activeSeasonTitle.value = _stringValue(data['title']).isNotEmpty
            ? _stringValue(data['title'])
            : 'Season Utama';
        seasonDurationDays.value = _intValue(data['durationDays'], fallback: 30);
        isLoading.value = false;
        _completeFirstLoad();
      },
      onError: (_) {
        errorMessage.value = 'Gagal memuat config season aktif.';
        activeSeasonId.value = fallbackSeasonId;
        activeSeasonTitle.value = 'Season Utama';
        seasonDurationDays.value = 30;
        isLoading.value = false;
        _completeFirstLoad();
      },
    );
  }

  Future<void> ensureLoaded({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!isLoading.value) return;
    final completer = _firstLoadCompleter;
    if (completer == null) return;
    await completer.future.timeout(timeout, onTimeout: () {});
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  String _stringValue(Object? value) => value?.toString().trim() ?? '';

  int _intValue(Object? value, {required int fallback}) {
    return value is num && value.toInt() > 0 ? value.toInt() : fallback;
  }

  void _completeFirstLoad() {
    final completer = _firstLoadCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }
}
