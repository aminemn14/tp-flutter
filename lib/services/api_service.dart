import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tp_flutter/env.dart';
import 'package:tp_flutter/models/question.dart';

class ApiService {
  static final Map<String, String> _headers = {
    'x-rapidapi-key': Env.rapidApiKey,
    'x-rapidapi-host': 'quizmania-api.p.rapidapi.com',
    'Content-Type': 'application/json',
  };

  /// renvoie une seule question
  static Future<Question> fetchRandomTrivia() async {
    final uri = Uri.parse('${Env.baseUrl}/random-trivia');
    final response = await http.get(uri, headers: _headers);

    print('[DEBUG] fetchRandomTrivia → URL: $uri');
    print('[DEBUG] fetchRandomTrivia → status: ${response.statusCode}');
    print('[DEBUG] fetchRandomTrivia → body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erreur fetchRandomTrivia (code ${response.statusCode})');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return Question.fromJson(data);
  }

  /// renvoie la liste brute de toutes les questions (déjà écrite)
  static Future<List<Question>> fetchAllTrivia() async {
    final uri = Uri.parse('${Env.baseUrl}/trivia');
    final response = await http.get(uri, headers: _headers);

    print('[DEBUG] fetchAllTrivia → URL: $uri');
    print('[DEBUG] fetchAllTrivia → status: ${response.statusCode}');
    print('[DEBUG] fetchAllTrivia → body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erreur fetchAllTrivia (code ${response.statusCode})');
    }

    final decoded = json.decode(response.body);
    if (decoded is List) {
      return _parseQuestionsList(decoded);
    } else {
      print(
        '[ERROR] fetchAllTrivia → attendu List, reçu ${decoded.runtimeType}',
      );
      return <Question>[];
    }
  }

  /// récupère TOUTES les questions, puis filtre et retourne jusqu’à 10 items
  static Future<List<Question>> fetchByCategoryThenFilter({
    required String category,
    required String difficulty,
  }) async {
    print(
      '[DEBUG] fetchByCategoryThenFilter → catégorie: $category, difficulté: $difficulty',
    );

    // 1) Récupérer la liste complète de questions
    final allQuestions = await fetchAllTrivia();
    print(
      '[DEBUG] fetchByCategoryThenFilter → total questions récupérées : ${allQuestions.length}',
    );

    // 2) Filtrer localement sur la catégorie ET la difficulté
    final filtered =
        allQuestions.where((q) {
          return q.category.toLowerCase().trim() ==
                  category.toLowerCase().trim() &&
              q.difficulty.toLowerCase().trim() ==
                  difficulty.toLowerCase().trim();
        }).toList();

    print(
      '[DEBUG] fetchByCategoryThenFilter → questions après filtre "${category}/${difficulty}" : ${filtered.length}',
    );

    // 3) Mélanger (shuffle) la liste filtrée pour obtenir un ordre aléatoire
    filtered.shuffle();

    // 4) Si on a plus de 10 questions, on ne prend que les 10 premières
    if (filtered.length > 10) {
      return filtered.sublist(0, 10);
    } else {
      return filtered; // on retourne tout ce qu'on a (moins de 10)
    }
  }

  /// renvoie un objet avec une clé contenant la liste
  static Future<List<Question>> fetchTriviaByCategory(String category) async {
    final uri = Uri.parse(
      '${Env.baseUrl}/trivia-by-category?category=$category',
    );
    final response = await http.get(uri, headers: _headers);

    print('[DEBUG] fetchTriviaByCategory → URL: $uri');
    print('[DEBUG] fetchTriviaByCategory → status: ${response.statusCode}');
    print('[DEBUG] fetchTriviaByCategory → body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur fetchTriviaByCategory (code ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body);

    // 1) Si l'API renvoie un OBJET unique qui contient directement une question…
    if (decoded is Map<String, dynamic> && decoded.containsKey('question')) {
      // On construit un objet Question unique
      final oneQuestion = Question.fromJson(decoded);
      return [oneQuestion];
    }

    // 2) Sinon, on essaye comme avant de récupérer une liste de questions dans le Map
    if (decoded is Map<String, dynamic>) {
      List<dynamic>? questionsList;

      if (decoded.containsKey('questions')) {
        questionsList = decoded['questions'] as List<dynamic>?;
      } else if (decoded.containsKey('data')) {
        questionsList = decoded['data'] as List<dynamic>?;
      } else if (decoded.containsKey('trivia')) {
        questionsList = decoded['trivia'] as List<dynamic>?;
      } else if (decoded.containsKey('results')) {
        questionsList = decoded['results'] as List<dynamic>?;
      } else {
        print('[DEBUG] Structure de la réponse: ${decoded.keys.toList()}');
        print('[DEBUG] Contenu complet: $decoded');
        for (final value in decoded.values) {
          if (value is List) {
            questionsList = value;
            break;
          }
        }
      }

      if (questionsList != null) {
        print(
          '[DEBUG] fetchTriviaByCategory → nombre total : ${questionsList.length}',
        );
        return _parseQuestionsList(questionsList);
      } else {
        print(
          '[ERROR] fetchTriviaByCategory → aucune liste trouvée dans la réponse',
        );
        return <Question>[];
      }
    } else if (decoded is List) {
      // Cas où l'API renverrait directement une liste
      print(
        '[DEBUG] fetchTriviaByCategory → nombre total : ${(decoded as List).length}',
      );
      return _parseQuestionsList(decoded);
    } else {
      print(
        '[ERROR] fetchTriviaByCategory → type inattendu: ${decoded.runtimeType}',
      );
      return <Question>[];
    }
  }

  /// renvoie une liste brute JSON
  static Future<List<Question>> fetchTriviaByDifficulty(
    String difficulty,
  ) async {
    final uri = Uri.parse(
      '${Env.baseUrl}/trivia-by-difficulty?difficulty=$difficulty',
    );
    final response = await http.get(uri, headers: _headers);

    print('[DEBUG] fetchTriviaByDifficulty → URL: $uri');
    print('[DEBUG] fetchTriviaByDifficulty → status: ${response.statusCode}');
    print('[DEBUG] fetchTriviaByDifficulty → body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur fetchTriviaByDifficulty (code ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body);

    // Même logique que pour fetchTriviaByCategory
    if (decoded is Map<String, dynamic>) {
      List<dynamic>? questionsList;

      if (decoded.containsKey('questions')) {
        questionsList = decoded['questions'] as List<dynamic>?;
      } else if (decoded.containsKey('data')) {
        questionsList = decoded['data'] as List<dynamic>?;
      } else if (decoded.containsKey('trivia')) {
        questionsList = decoded['trivia'] as List<dynamic>?;
      } else if (decoded.containsKey('results')) {
        questionsList = decoded['results'] as List<dynamic>?;
      } else {
        print(
          '[DEBUG] Structure de la réponse difficulty: ${decoded.keys.toList()}',
        );
        for (final value in decoded.values) {
          if (value is List) {
            questionsList = value;
            break;
          }
        }
      }

      if (questionsList != null) {
        print(
          '[DEBUG] fetchTriviaByDifficulty → nombre total : ${questionsList.length}',
        );
        return _parseQuestionsList(questionsList);
      } else {
        return <Question>[];
      }
    } else if (decoded is List) {
      print(
        '[DEBUG] fetchTriviaByDifficulty → nombre total : ${(decoded as List).length}',
      );
      return _parseQuestionsList(decoded);
    } else {
      print(
        '[ERROR] fetchTriviaByDifficulty → attendu List, reçu ${decoded.runtimeType}',
      );
      return <Question>[];
    }
  }

  /// renvoie un objet contenant une seule question aléatoire
  static Future<List<Question>> fetchTriviaFiltered({
    String? category,
    String? difficulty,
  }) async {
    final queryParameters = <String, String>{};
    if (category != null) queryParameters['category'] = category;
    if (difficulty != null) queryParameters['difficulty'] = difficulty;

    final uri = Uri.parse(
      '${Env.baseUrl}/trivia-filtered',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: _headers);

    print('[DEBUG] fetchTriviaFiltered → URL: $uri');
    print('[DEBUG] fetchTriviaFiltered → status: ${response.statusCode}');
    print('[DEBUG] fetchTriviaFiltered → body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur fetchTriviaFiltered (code ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final single = decoded['question'] as Map<String, dynamic>;
    return [Question.fromJson(single)];
  }

  /// renvoie { "categories": [ "Science", "Geography", … ] }
  static Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('${Env.baseUrl}/categories');
    final response = await http.get(uri, headers: _headers);

    print('[DEBUG] fetchCategories → URL: $uri');
    print('[DEBUG] fetchCategories → status: ${response.statusCode}');
    print('[DEBUG] fetchCategories → body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erreur fetchCategories (code ${response.statusCode})');
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('categories')) {
      final cats = decoded['categories'];
      if (cats is List) {
        print(
          '[DEBUG] fetchCategories → nombre de catégories : ${cats.length}',
        );
        return List<String>.from(cats);
      } else {
        print(
          '[ERROR] fetchCategories → "categories" existe mais n est pas une List',
        );
        return <String>[];
      }
    }

    print('[DEBUG] Structure de la réponse categories: ${decoded.runtimeType}');
    if (decoded is Map) {
      print('[DEBUG] Clés disponibles: ${(decoded as Map).keys.toList()}');
    }
    return <String>[];
  }

  /// Méthode helper pour parser une liste de questions avec gestion d'erreurs
  static List<Question> _parseQuestionsList(List<dynamic> questionsList) {
    final List<Question> questions = [];

    for (int i = 0; i < questionsList.length; i++) {
      try {
        final item = questionsList[i];
        print('[DEBUG] Parsing item $i: ${item.runtimeType}');

        if (item is Map<String, dynamic>) {
          final question = Question.fromJson(item);
          questions.add(question);
        } else if (item is String) {
          print('[WARNING] Item $i est un String au lieu d\'un Map: $item');
          // Essayer de parser le String comme JSON
          try {
            final parsed = json.decode(item);
            if (parsed is Map<String, dynamic>) {
              final question = Question.fromJson(parsed);
              questions.add(question);
            }
          } catch (e) {
            print('[ERROR] Impossible de parser le String comme JSON: $e');
          }
        } else {
          print('[WARNING] Item $i type inattendu: ${item.runtimeType}');
        }
      } catch (e) {
        print('[ERROR] Erreur lors du parsing de l\'item $i: $e');
        print('[ERROR] Contenu de l\'item: ${questionsList[i]}');
        // Continue avec les autres questions au lieu de planter
        continue;
      }
    }

    print(
      '[DEBUG] _parseQuestionsList → ${questions.length} questions parsées avec succès',
    );
    return questions;
  }
}
