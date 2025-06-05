import 'package:flutter/material.dart';
import 'package:tp_flutter/models/question.dart';
import 'package:tp_flutter/services/api_service.dart';

class QuizRandomScreen extends StatefulWidget {
  const QuizRandomScreen({super.key});

  @override
  State<QuizRandomScreen> createState() => _QuizRandomScreenState();
}

class _QuizRandomScreenState extends State<QuizRandomScreen> {
  late Future<List<Question>> _questionsFuture;
  List<Question>? _questions;
  int _currentIndex = 0;
  int _score = 0;
  bool _showResult = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    // Au démarrage : on lance le chargement des 10 questions aléatoires
    _questionsFuture = _fetchTenRandomQuestions();
  }

  // Lance 10 appels à fetchRandomTrivia() en parallèle
  Future<List<Question>> _fetchTenRandomQuestions() {
    return Future.wait(
      List.generate(10, (_) => ApiService.fetchRandomTrivia()),
    );
  }

  // Appelé quand on clique sur une réponse
  void _onAnswerSelected(String answer) {
    final currentQuestion = _questions![_currentIndex];
    final bool isCorrect = answer == currentQuestion.correct;

    setState(() {
      _selectedAnswer = answer;
      if (isCorrect) {
        _score++;
      }
      _showResult = true;
    });
  }

  void _onNextPressed() {
    // Si on est à la dernière question, on affiche l'AlertDialog
    if (_currentIndex == _questions!.length - 1) {
      _showFinalResult();
    } else {
      // Sinon, on passe à la question suivante
      setState(() {
        _currentIndex++;
        _showResult = false;
        _selectedAnswer = null;
      });
    }
  }

  // Méthode pour afficher le score final dans une AlertDialog
  void _showFinalResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Final Score'),
            content: Text(
              'Your score : $_score / ${_questions!.length}',
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

  // Pour relancer un nouveau quiz de 10 questions
  void _restartQuiz() {
    setState(() {
      _questionsFuture = _fetchTenRandomQuestions();
      _questions = null;
      _currentIndex = 0;
      _score = 0;
      _showResult = false;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Quiz'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Question>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            // tant que le chargement n'est pas terminé, on affiche un Loader
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // en cas d'erreur lors du fetch
            else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading questions: ${snapshot.error}'),
              );
            }
            // une fois qu'on a bien récupéré la liste de 10 questions
            else {
              // stocker définitivement la liste dans _questions (pour ne pas recharger à chaque build)
              _questions ??= snapshot.data!;

              final question = _questions![_currentIndex];

              if (!_showResult) {
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

  /// Affiche la vue d’une question (texte + boutons réponses)
  Widget _buildQuestionView(Question question) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicateur « Question X / 10 »
          Text(
            'Question ${_currentIndex + 1} / 10',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // Texte de la question
          Text(
            question.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Boutons des réponses
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

  /// Affiche la vue de résultat pour la question courante
  Widget _buildResultView(Question question) {
    final bool isCorrect = _selectedAnswer == question.correct;

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

          // Explication
          const Text(
            'Explanation :',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(question.explanation, style: const TextStyle(fontSize: 16)),

          const Spacer(),

          // Si on est à la dernière question (_currentIndex == 9), on propose « See Score »,
          // sinon on propose « Next Question »
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
              _currentIndex == _questions!.length - 1
                  ? 'See Score'
                  : 'Next Question',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
