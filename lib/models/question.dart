class Question {
  final String question;
  final List<String> answers;
  final String correct;
  final String category;
  final String explanation;
  final String difficulty;

  Question({
    required this.question,
    required this.answers,
    required this.correct,
    required this.category,
    required this.explanation,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> answersList = [];
    if (json['answers'] is List) {
      answersList = List<String>.from(json['answers']);
    } else if (json['answers'] is Map) {
      answersList =
          (json['answers'] as Map).values.map((e) => e.toString()).toList();
    }

    return Question(
      question: json['question'] as String,
      answers: answersList,
      correct: json['correct'] as String,
      category: json['category'] as String,
      explanation: json['explanation'] as String,
      difficulty: json['difficulty'] as String,
    );
  }
}
