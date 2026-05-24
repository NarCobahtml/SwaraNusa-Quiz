class QuizAnswer {
  final int questionNumber;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? imagePath;

  const QuizAnswer({
    required this.questionNumber,
    required this.userAnswer,
    required this.correctAnswer,
    this.imagePath,
  }) : isCorrect = userAnswer == correctAnswer;
}

class ReviewAnswersData {
  const ReviewAnswersData._();

  static List<QuizAnswer> getSampleData() {
    return const [
      QuizAnswer(
        questionNumber: 1,
        userAnswer: 'Tifa',
        correctAnswer: 'Tifa',
        imagePath: 'assets/image/gambar_tifa.png',
      ),
      QuizAnswer(
        questionNumber: 2,
        userAnswer: 'Sasando',
        correctAnswer: 'Gamelan',
        imagePath: 'assets/image/gambar_gamelan.png',
      ),
      QuizAnswer(
        questionNumber: 3,
        userAnswer: 'Kolintang',
        correctAnswer: 'Kolintang',
        imagePath: 'assets/image/gambar_kolintang.png',
      ),
      QuizAnswer(
        questionNumber: 4,
        userAnswer: 'Gambus',
        correctAnswer: 'Gambus',
        imagePath: 'assets/image/gambar_gambus.png',
      ),
      QuizAnswer(
        questionNumber: 5,
        userAnswer: 'Sape',
        correctAnswer: 'Sasando',
        imagePath: 'assets/image/gambar_sasando.png',
      ),
      QuizAnswer(
        questionNumber: 6,
        userAnswer: 'Gamelan',
        correctAnswer: 'Rebab',
        imagePath: 'assets/image/gambar_rebab.png',
      ),
      QuizAnswer(
        questionNumber: 7,
        userAnswer: 'Angklung',
        correctAnswer: 'Angklung',
        imagePath: 'assets/image/gambar_angklung.png',
      ),
      QuizAnswer(
        questionNumber: 8,
        userAnswer: 'Gendang',
        correctAnswer: 'Gendang',
        imagePath: 'assets/image/gambar_gendang.png',
      ),
      QuizAnswer(
        questionNumber: 9,
        userAnswer: 'Sape',
        correctAnswer: 'Sape',
        imagePath: 'assets/image/gambar_sape.png',
      ),
      QuizAnswer(
        questionNumber: 10,
        userAnswer: 'Kecapi',
        correctAnswer: 'Kecapi',
        imagePath: 'assets/image/gambar_kecapi.png',
      ),
    ];
  }
}
