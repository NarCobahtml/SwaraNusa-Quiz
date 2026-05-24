import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';

abstract final class QuizFallbackQuestions {
  static const tebakGambarLevel1 = QuizSessionConfig(
    title: 'Tebak Gambar',
    modeId: 'tebak_gambar',
    levelId: 'tebak_gambar_1',
  );

  static const tebakSuaraLevel1 = QuizSessionConfig(
    title: 'Tebak Suara',
    modeId: 'tebak_suara',
    levelId: 'tebak_suara_1',
  );

  static const sejarahLevel1 = QuizSessionConfig(
    title: 'Sejarah',
    modeId: 'sejarah',
    levelId: 'sejarah_1',
  );

  static List<QuizSessionQuestion> forConfig(QuizSessionConfig config) {
    switch (config.levelId) {
      case 'tebak_suara_1':
        return tebakSuara;
      case 'sejarah_1':
        return sejarah;
      case 'tebak_gambar_1':
      default:
        return tebakGambar;
    }
  }

  static const List<QuizSessionQuestion> tebakGambar = [
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q1',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 1,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_tifa.png',
      options: ['Tifa', 'Kolintang', 'Gamelan', 'Angklung'],
      correctAnswer: 'Tifa',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q2',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 2,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_gamelan.png',
      options: ['Sasando', 'Tifa', 'Angklung', 'Gamelan'],
      correctAnswer: 'Gamelan',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q3',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 3,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_kolintang.png',
      options: ['Tifa', 'Kolintang', 'Gamelan', 'Angklung'],
      correctAnswer: 'Kolintang',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q4',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 4,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_gambus.png',
      options: ['Tifa', 'Gendang', 'Sape', 'Gambus'],
      correctAnswer: 'Gambus',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q5',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 5,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_sasando.png',
      options: ['Gamelan', 'Sape', 'Gamelan', 'Sasando'],
      correctAnswer: 'Sasando',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q6',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 6,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_rebab.png',
      options: ['Rebab', 'Angklung', 'Gamelan', 'Kolintang'],
      correctAnswer: 'Rebab',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q7',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 7,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_angklung.png',
      options: ['Gendang', 'Sape', 'Kolintang', 'Angklung'],
      correctAnswer: 'Angklung',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q8',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 8,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_gendang.png',
      options: ['Kolintang', 'Sape', 'Gendang', 'Gambus'],
      correctAnswer: 'Gendang',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q9',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 9,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_sape.png',
      options: ['Sape', 'Kolintang', 'Gamelan', 'Angklung'],
      correctAnswer: 'Sape',
    ),
    QuizSessionQuestion(
      id: 'tebak_gambar_1_q10',
      modeId: 'tebak_gambar',
      levelId: 'tebak_gambar_1',
      questionNumber: 10,
      title: 'Tebak Gambar',
      questionText: '',
      mediaType: QuizMediaType.image,
      mediaUrl: 'assets/image/gambar_kecapi.png',
      options: ['Gendang', 'Tifa', 'Kecapi', 'Rebab'],
      correctAnswer: 'Kecapi',
    ),
  ];

  static const List<QuizSessionQuestion> tebakSuara = [
    QuizSessionQuestion(
      id: 'tebak_suara_1_q1',
      modeId: 'tebak_suara',
      levelId: 'tebak_suara_1',
      questionNumber: 1,
      title: 'Tebak Suara',
      questionText: 'Dengarkan suara alat musik ini.',
      mediaType: QuizMediaType.audio,
      mediaUrl: 'assets/audio/suara_angklung.mp3',
      options: ['Angklung', 'Gamelan', 'Kolintang', 'Sasando'],
      correctAnswer: 'Angklung',
    ),
  ];

  static const List<QuizSessionQuestion> sejarah = [
    QuizSessionQuestion(
      id: 'sejarah_1_q1',
      modeId: 'sejarah',
      levelId: 'sejarah_1',
      questionNumber: 1,
      title: 'Sejarah',
      questionText:
          'Kolintang adalah alat musik tradisional dari Minahasa, Sulawesi Utara. Dahulu, kolintang digunakan untuk...',
      mediaType: QuizMediaType.text,
      mediaUrl: '',
      options: [
        'Mengiringi pertunjukan wayang',
        'Tanda dimulainya perdagangan',
        'Mengiringi upacara adat tarian',
        'Lagu-lagu kerajaan Jawa',
      ],
      correctAnswer: 'Mengiringi upacara adat tarian',
    ),
  ];
}
