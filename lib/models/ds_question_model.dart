/// Model for a Data Structures quiz question from Supabase.
class DsQuestion {
  final String id;
  final String topic;
  final String difficulty;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption; // 'A', 'B', 'C', or 'D'
  final String? explanation;

  const DsQuestion({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.explanation,
  });

  factory DsQuestion.fromJson(Map<String, dynamic> json) {
    return DsQuestion(
      id: json['id'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      questionText: json['question_text'] as String,
      optionA: json['option_a'] as String,
      optionB: json['option_b'] as String,
      optionC: json['option_c'] as String,
      optionD: json['option_d'] as String,
      correctOption: json['correct_option'] as String,
      explanation: json['explanation'] as String?,
    );
  }

  /// Get the correct answer text based on correctOption letter.
  String get correctAnswerText {
    switch (correctOption.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return optionA;
    }
  }

  /// Get option text by letter.
  String getOptionText(String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }
}
