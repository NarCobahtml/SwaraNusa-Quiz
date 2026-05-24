import 'package:swaranusaquiz/app/data/models/backend_models.dart';

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
        return QuizMediaType.text;
      case 'image':
      case 'gambar':
      default:
        return QuizMediaType.image;
    }
  }
}

class QuizSessionQuestion {
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

  const QuizSessionQuestion({
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

  factory QuizSessionQuestion.fromDoc(QuestionDoc doc) {
    return QuizSessionQuestion(
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
