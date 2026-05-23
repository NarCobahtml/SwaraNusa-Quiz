import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:swaranusaquiz/app/data/models/backend_models.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';

class BackendBootstrap {
  BackendBootstrap._();

  static final BackendBootstrap instance = BackendBootstrap._();

  final authRepository = AuthRepository();
  final userRepository = UserRepository();
  final contentRepository = ContentRepository();

  AppUser? currentUser;
  List<QuizModeDoc> quizModes = const [];
  final Map<String, List<LevelDoc>> levelsByMode = {};
  final Map<String, QuestionDoc> questionsById = {};
  List<LeaderboardEntryDoc> leaderboard = const [];
  List<InstrumentDoc> instruments = const [];
  List<MissionDoc> missions = const [];
  List<BadgeDoc> badges = const [];
  Future<void>? _initializeFuture;

  Future<void> initializeOnce() {
    return _initializeFuture ??= initialize();
  }

  Future<void> initialize() async {
    await loadPublicContent();
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUser = await userRepository.currentUserProfile(user.uid);
    }
  }

  Future<void> loadPublicContent() async {
    quizModes = await contentRepository.loadModes();
    levelsByMode
      ..clear()
      ..addEntries(
        await Future.wait(
          quizModes.map(
            (mode) async => MapEntry(
              mode.id,
              await contentRepository.loadLevels(mode.id),
            ),
          ),
        ),
      );
    questionsById.clear();
    for (final levels in levelsByMode.values) {
      for (final level in levels) {
        if (!level.isActive) continue;
        final questions = await contentRepository.loadQuestions(level.id);
        questionsById.addEntries(
          questions.map((question) => MapEntry(question.id, question)),
        );
      }
    }
    leaderboard = await contentRepository.loadLeaderboard();
    instruments = await contentRepository.loadInstruments();
    missions = await contentRepository.loadMissions();
    badges = await contentRepository.loadBadges();
  }

  Future<void> reloadUser() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    currentUser = user == null
        ? null
        : await userRepository.currentUserProfile(user.uid);
  }
}
