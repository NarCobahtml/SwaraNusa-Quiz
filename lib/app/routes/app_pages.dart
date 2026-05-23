import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/leaderboard_user.dart';
import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/modules/auth/bindings/forgot_password_binding.dart';
import 'package:swaranusaquiz/app/modules/auth/bindings/login_binding.dart';
import 'package:swaranusaquiz/app/modules/auth/bindings/signup_binding.dart';
import 'package:swaranusaquiz/app/modules/auth/views/forgot_password.dart';
import 'package:swaranusaquiz/app/modules/auth/views/login.dart';
import 'package:swaranusaquiz/app/modules/auth/views/signup.dart';
import 'package:swaranusaquiz/app/modules/guess_sound/bindings/guess_sound_binding.dart';
import 'package:swaranusaquiz/app/modules/guess_sound/views/tebak/tebak_pertanyaan/tebak_pertanyaan1.dart';
import 'package:swaranusaquiz/app/modules/history_quiz/bindings/history_quiz_binding.dart';
import 'package:swaranusaquiz/app/modules/history_quiz/views/sejarah/sejarah_pertanyaan/sejarah_pertanyaan1.dart';
import 'package:swaranusaquiz/app/modules/home/bindings/home_binding.dart';
import 'package:swaranusaquiz/app/modules/home/views/home_page.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/bindings/leaderboard_binding.dart';
import 'package:swaranusaquiz/app/modules/leaderboard/views/leaderboard.dart';
import 'package:swaranusaquiz/app/modules/level_selection/bindings/level_binding.dart';
import 'package:swaranusaquiz/app/modules/level_selection/views/level.dart';
import 'package:swaranusaquiz/app/modules/level_selection/views/level_sejarah.dart';
import 'package:swaranusaquiz/app/modules/level_selection/views/level_tebak_gambar.dart';
import 'package:swaranusaquiz/app/modules/level_selection/views/level_tebak_suara.dart';
import 'package:swaranusaquiz/app/modules/main_navigation/bindings/main_navigation_binding.dart';
import 'package:swaranusaquiz/app/modules/main_navigation/views/main_navigatian.dart';
import 'package:swaranusaquiz/app/modules/minigame/bindings/gamelan_minigame_binding.dart';
import 'package:swaranusaquiz/app/modules/minigame/views/gamelan_minigame.dart';
import 'package:swaranusaquiz/app/modules/mode/bindings/mode_binding.dart';
import 'package:swaranusaquiz/app/modules/mode/views/mode_page.dart';
import 'package:swaranusaquiz/app/modules/profile/bindings/profile_binding.dart';
import 'package:swaranusaquiz/app/modules/profile/views/profil.dart';
import 'package:swaranusaquiz/app/modules/quiz/bindings/quiz_question_binding.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_pertanyaan/kuis_pertanyaan1.dart';
import 'package:swaranusaquiz/app/modules/result/bindings/result_binding.dart';
import 'package:swaranusaquiz/app/modules/result/models/quiz_result_summary.dart';
import 'package:swaranusaquiz/app/modules/result/views/result.dart';
import 'package:swaranusaquiz/app/modules/review/bindings/review_binding.dart';
import 'package:swaranusaquiz/app/modules/review/views/review.dart';
import 'package:swaranusaquiz/app/modules/reward/bindings/reward_binding.dart';
import 'package:swaranusaquiz/app/modules/reward/views/reward_page.dart';
import 'package:swaranusaquiz/app/modules/splash/bindings/splash_binding.dart';
import 'package:swaranusaquiz/app/modules/splash/views/splash_screen.dart';

import 'app_routes.dart';

export 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreenSvg(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const MainNavigation(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.mode,
      page: () => const ModePage(),
      binding: ModeBinding(),
    ),
    GetPage(
      name: AppRoutes.leaderboard,
      page: () =>
          LeaderboardScreen(leaderboardData: LeaderboardData.getSampleData()),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: AppRoutes.reward,
      page: () => const RewardPage(),
      binding: RewardBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.level,
      page: () => const LevelSelectionPage(),
      binding: LevelBinding(),
    ),
    GetPage(
      name: AppRoutes.levelTebakGambar,
      page: () => const LevelTebakGambar(),
      binding: LevelBinding(),
    ),
    GetPage(
      name: AppRoutes.levelTebakSuara,
      page: () => const LevelTebakSuara(),
      binding: LevelBinding(),
    ),
    GetPage(
      name: AppRoutes.levelSejarah,
      page: () => const LevelSejarah(),
      binding: LevelBinding(),
    ),
    GetPage(
      name: AppRoutes.gamelanMinigame,
      page: () => const GamelanMinigamePage(),
      binding: GamelanMinigameBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () {
        final summary = Get.arguments is QuizResultSummary
            ? Get.arguments as QuizResultSummary
            : const QuizResultSummary(
                correctAnswers: 8,
                wrongAnswers: 2,
                totalQuestions: 10,
              );

        return QuizResultScreen(
          correctAnswers: summary.correctAnswers,
          wrongAnswers: summary.wrongAnswers,
          totalQuestions: summary.totalQuestions,
        );
      },
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => ReviewAnswersScreen(
        answers: Get.arguments is List<QuizAnswer>
            ? Get.arguments as List<QuizAnswer>
            : ReviewAnswersData.getSampleData(),
      ),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.kuisPertanyaan1,
      page: () => const KuisPertanyaan1(),
      binding: QuizQuestionBinding(),
    ),
    GetPage(
      name: AppRoutes.tebakPertanyaan1,
      page: () => const TebakPertanyaan1(),
      binding: GuessSoundBinding(),
    ),
    GetPage(
      name: AppRoutes.sejarahPertanyaan1,
      page: () => const SejarahPertanyaan1(),
      binding: HistoryQuizBinding(),
    ),
  ];
}
