import 'package:flutter/material.dart';
import 'package:tp_flutter/models/question.dart';
import 'package:tp_flutter/services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  final String category;
  final String? initialDifficulty;

  const CategoriesScreen({
    super.key,
    required this.category,
    this.initialDifficulty,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late String? _selectedDifficulty;
  late Future<List<Question>> _questionsFuture;
  List<Question>? _quizQuestions;
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _loadQuestions();
  }

  void _loadQuestions() {
    if (_selectedDifficulty == null) {
      // Récupérer toutes les questions de la catégorie
      _questionsFuture = ApiService.fetchTriviaByCategory(widget.category);
    } else {
      // Utiliser la méthode qui récupère par catégorie puis filtre
      _questionsFuture = ApiService.fetchByCategoryThenFilter(
        category: widget.category,
        difficulty: _selectedDifficulty!,
      );
    }
    _quizQuestions = null;
    _currentIndex = 0;
    _score = 0;
    _answered = false;
    _selectedAnswer = null;
  }

  void _onAnswerSelected(String answer) {
    if (_answered) return;
    final currentQuestion = _quizQuestions![_currentIndex];
    final bool isCorrect = (answer == currentQuestion.correct);

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _onNextPressed() {
    if (_currentIndex < _quizQuestions!.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _showFinalResult();
    }
  }

  void _showFinalResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Final Score'),
            content: Text(
              'Your score : $_score / ${_quizQuestions!.length}',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx)
                    ..pop()
                    ..pop();
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
    );
  }

  void _restartQuiz() {
    setState(() {
      _loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleText =
        widget.category +
        (_selectedDifficulty != null ? ' – ${_selectedDifficulty!}' : '');

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Question>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Erreur lors du chargement : ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              final allQuestions = snapshot.data!;
              if (allQuestions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Aucune question disponible pour ce filtre.',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              }

              _quizQuestions ??= () {
                final shuffled = List<Question>.from(allQuestions);
                shuffled.shuffle();
                return (shuffled.length >= 10)
                    ? shuffled.sublist(0, 10)
                    : shuffled;
              }();

              if (_currentIndex >= _quizQuestions!.length) {
                return _buildFinalScoreView(context);
              }

              final question = _quizQuestions![_currentIndex];
              if (!_answered) {
                return _buildQuestionView(question);
              } else {
                return _buildResultView(question);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuestionView(Question question) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_currentIndex + 1} / ${_quizQuestions!.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...question.answers.map((answer) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color(0xFF1E88E5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _onAnswerSelected(answer),
                child: Text(answer, style: const TextStyle(fontSize: 16)),
              ),
            );
          }),
          const Spacer(),

          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Restart Quiz',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            onPressed: _restartQuiz,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(Question question) {
    final isCorrect = (_selectedAnswer == question.correct);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            isCorrect ? 'Correct answer!' : 'Wrong answer…',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          if (!isCorrect && _selectedAnswer != null)
            Text(
              'Your answer : $_selectedAnswer\nCorrect answer : ${question.correct}',
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 24),
          const Text(
            'Explanation :',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(question.explanation, style: const TextStyle(fontSize: 16)),
          const Spacer(),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            onPressed: _onNextPressed,
            child: Text(
              _currentIndex < _quizQuestions!.length - 1
                  ? 'Next Question'
                  : 'See Score',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScoreView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quiz finished !',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            'Your score : $_score / ${_quizQuestions!.length}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _restartQuiz,
            child: const Text('Restart Another Quiz'),
          ),
        ],
      ),
    );
  }
}
