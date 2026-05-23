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
        imagePath: 'assets/image/Gambar Tifa.png',
      ),
      QuizAnswer(
        questionNumber: 2,
        userAnswer: 'Sasando',
        correctAnswer: 'Gamelan',
        imagePath: 'assets/image/Gambar Gamelan.png',
      ),
      QuizAnswer(
        questionNumber: 3,
        userAnswer: 'Kolintang',
        correctAnswer: 'Kolintang',
        imagePath: 'assets/image/Gambar Kolintang.png',
      ),
      QuizAnswer(
        questionNumber: 4,
        userAnswer: 'Gambus',
        correctAnswer: 'Gambus',
        imagePath: 'assets/image/Gambar Gambus.png',
      ),
      QuizAnswer(
        questionNumber: 5,
        userAnswer: 'Sape',
        correctAnswer: 'Sasando',
        imagePath: 'assets/image/Gambar Sape.png',
      ),
      QuizAnswer(
        questionNumber: 6,
        userAnswer: 'Gamelan',
        correctAnswer: 'Rebab',
        imagePath: 'assets/image/Gambar Rebab.png',
      ),
      QuizAnswer(
        questionNumber: 7,
        userAnswer: 'Angklung',
        correctAnswer: 'Angklung',
        imagePath: 'assets/image/Gambar Angklung.png',
      ),
      QuizAnswer(
        questionNumber: 8,
        userAnswer: 'Gendang',
        correctAnswer: 'Gendang',
        imagePath: 'assets/image/Gambar Gendang.png',
      ),
      QuizAnswer(
        questionNumber: 9,
        userAnswer: 'Sape',
        correctAnswer: 'Sape',
        imagePath: 'assets/image/Gambar Sape.png',
      ),
      QuizAnswer(
        questionNumber: 10,
        userAnswer: 'Kecapi',
        correctAnswer: 'Kecapi',
        imagePath: 'assets/image/Gambar Kecapi.png',
      ),
    ];
  }
}
