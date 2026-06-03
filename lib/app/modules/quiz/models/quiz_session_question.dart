import 'package:swaranusaquiz/app/data/models/backend_models.dart';

enum QuizType {
  tebakGambar,
  tebakSuara,
  sejarah,
  unknown;

  static QuizType fromModeId(String value) {
    switch (value.trim().toLowerCase()) {
      case 'tebak_gambar':
        return QuizType.tebakGambar;
      case 'tebak_suara':
        return QuizType.tebakSuara;
      case 'sejarah':
        return QuizType.sejarah;
      default:
        return QuizType.unknown;
    }
  }
}

enum QuizMediaType {
  image,
  audio,
  text;

  static QuizMediaType fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'audio':
      case 'sound':
        return QuizMediaType.audio;
      case 'text':
      case 'history':
      case 'none':
      case 'no_media':
        return QuizMediaType.text;
      case 'image':
      case 'gambar':
      default:
        return QuizMediaType.image;
    }
  }
}

class QuizOption {
  final String id;
  final String text;

  const QuizOption({
    required this.id,
    required this.text,
  });
}

class QuizQuestion {
  final String id;
  final String modeId;
  final String levelId;
  final int questionNumber;
  final String title;
  final String questionText;
  final QuizMediaType mediaType;
  final String mediaUrl;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int timeLimitSeconds;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.modeId,
    required this.levelId,
    required this.questionNumber,
    required this.title,
    required this.questionText,
    required this.mediaType,
    required this.mediaUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
    this.timeLimitSeconds = 45,
    this.points = 10,
  });

  QuizType get type => QuizType.fromModeId(modeId);

  List<QuizOption> get optionItems {
    return List<QuizOption>.generate(
      options.length,
      (index) => QuizOption(id: '${id}_option_$index', text: options[index]),
    );
  }

  factory QuizQuestion.fromDoc(QuestionDoc doc) {
    return QuizQuestion(
      id: doc.id,
      modeId: doc.modeId,
      levelId: doc.levelId,
      questionNumber: doc.questionNumber,
      title: doc.title,
      questionText: doc.questionText,
      mediaType: QuizMediaType.fromString(doc.mediaType),
      mediaUrl: doc.mediaUrl,
      options: doc.options,
      correctAnswer: doc.correctAnswer,
      explanation: doc.explanation,
      timeLimitSeconds: doc.timeLimitSeconds > 0 ? doc.timeLimitSeconds : 45,
      points: doc.points > 0 ? doc.points : 10,
    );
  }
}

class QuizSessionQuestion extends QuizQuestion {
  const QuizSessionQuestion({
    required super.id,
    required super.modeId,
    required super.levelId,
    required super.questionNumber,
    required super.title,
    required super.questionText,
    required super.mediaType,
    required super.mediaUrl,
    required super.options,
    required super.correctAnswer,
    super.explanation = '',
    super.timeLimitSeconds = 45,
    super.points = 10,
  });

  factory QuizSessionQuestion.fromDoc(QuestionDoc doc) {
    final question = QuizQuestion.fromDoc(doc);
    return QuizSessionQuestion(
      id: question.id,
      modeId: question.modeId,
      levelId: question.levelId,
      questionNumber: question.questionNumber,
      title: question.title,
      questionText: question.questionText,
      mediaType: question.mediaType,
      mediaUrl: question.mediaUrl,
      options: question.options,
      correctAnswer: question.correctAnswer,
      explanation: question.explanation,
      timeLimitSeconds: question.timeLimitSeconds,
      points: question.points,
    );
  }
}

class QuizResult {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final int score;

  const QuizResult({
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.score,
  });
}
