/// PromptCraft data models

class PromptLevel {
  final int levelNumber;
  final String title;
  final String icon; // Material icon name
  final String description;
  final List<PromptLesson> lessons;
  final List<PromptExamQuestion> examQuestions;
  final bool isSpecialLevel; // For levels 7, 8 with custom screens

  const PromptLevel({
    required this.levelNumber,
    required this.title,
    required this.icon,
    required this.description,
    required this.lessons,
    required this.examQuestions,
    this.isSpecialLevel = false,
  });
}

class PromptLesson {
  final String title;
  final String description;
  final String? assetPath;
  final String? tryPrompt; // Pre-filled prompt for "Try in Nova AI"

  const PromptLesson({
    required this.title,
    required this.description,
    this.assetPath,
    this.tryPrompt,
  });
}

class PromptExamQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const PromptExamQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class PromptBattleSubmission {
  final int? id;
  final int? studentId;
  final String studentName;
  final int taskId;
  final String promptText;
  final String aiOutput;
  final int score;
  final DateTime createdAt;

  const PromptBattleSubmission({
    this.id,
    this.studentId,
    required this.studentName,
    required this.taskId,
    required this.promptText,
    required this.aiOutput,
    this.score = 0,
    required this.createdAt,
  });

  factory PromptBattleSubmission.fromJson(Map<String, dynamic> json) {
    return PromptBattleSubmission(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['student_name'] ?? 'Anonymous',
      taskId: json['task_id'] ?? 0,
      promptText: json['prompt_text'] ?? '',
      aiOutput: json['ai_output'] ?? '',
      score: json['score'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'task_id': taskId,
      'prompt_text': promptText,
      'ai_output': aiOutput,
      'score': score,
    };
  }
}

class ImageTaskResult {
  final int similarityScore;
  final int colorMatch;
  final int compositionMatch;
  final int styleMatch;
  final List<String> missingElements;
  final List<String> improvementTips;

  const ImageTaskResult({
    required this.similarityScore,
    required this.colorMatch,
    required this.compositionMatch,
    required this.styleMatch,
    required this.missingElements,
    required this.improvementTips,
  });

  factory ImageTaskResult.fromJson(Map<String, dynamic> json) {
    return ImageTaskResult(
      similarityScore: json['similarity_score'] ?? 0,
      colorMatch: json['color_match'] ?? 0,
      compositionMatch: json['composition_match'] ?? 0,
      styleMatch: json['style_match'] ?? 0,
      missingElements: List<String>.from(json['missing_elements'] ?? []),
      improvementTips: List<String>.from(json['improvement_tips'] ?? []),
    );
  }
}
