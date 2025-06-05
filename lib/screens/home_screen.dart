import 'package:flutter/material.dart';
import 'package:tp_flutter/services/api_service.dart';
import 'package:tp_flutter/screens/quiz_random_screen.dart';
import 'package:tp_flutter/screens/quiz_screen.dart';
import 'package:tp_flutter/widgets/category_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> _categoriesFuture;

  // Regrouper les catégories sous des rubriques
  final Map<String, List<String>> _categoryGroups = {
    'Sciences': [
      'science',
      'biology',
      'chemistry',
      'physics',
      'astronomy',
      'geology',
      'medicine',
    ],
    'Arts & Culture': [
      'art',
      'literature',
      'music',
      'culture',
      'history',
      'mythology',
      'language',
      'linguistics',
    ],
    'Entertainment & Media': ['entertainment', 'youtubers/streamers', 'sports'],
    'General Knowledge': [
      'geography',
      'technology',
      'mathematics',
      'food',
      'animals',
      'landmarks',
      'philosophy',
      'economics',
    ],
    // Toute catégorie non référencée ci-dessus passe dans « Autres »
  };

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Welcome to Quiz Mania',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    } else {
                      final fetchedCategories = snapshot.data!;

                      // Map locale temporaire pour grouper les catégories disponibles
                      final Map<String, List<String>> availableGroups = {};
                      for (final entry in _categoryGroups.entries) {
                        final groupName = entry.key;
                        final groupListLower = entry.value;
                        final matched =
                            fetchedCategories.where((cat) {
                              return groupListLower.contains(cat.toLowerCase());
                            }).toList();
                        if (matched.isNotEmpty) {
                          availableGroups[groupName] = matched;
                        }
                      }

                      // Identifier les catégories non classées
                      final categorized =
                          availableGroups.values.expand((list) => list).toSet();
                      final uncategorized =
                          fetchedCategories
                              .where((cat) => !categorized.contains(cat))
                              .toList();
                      if (uncategorized.isNotEmpty) {
                        availableGroups['Autres'] = uncategorized;
                      }

                      final totalItems = availableGroups.length + 1;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: totalItems,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }

                          final groupIndex = index - 1;
                          final groupName = availableGroups.keys.elementAt(
                            groupIndex,
                          );
                          final groupCats = availableGroups[groupName]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                groupName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: groupCats.length,
                                  separatorBuilder:
                                      (context, _) => const SizedBox(width: 12),
                                  itemBuilder: (context, catIndex) {
                                    final category = groupCats[catIndex];
                                    return SizedBox(
                                      width: 140,
                                      child: CategoryTile(
                                        title: _formatCategoryTitle(category),
                                        onTap:
                                            () => _openCategory(
                                              context,
                                              category,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.shuffle, color: Colors.white),
                label: const Text(
                  'Quiz Aléatoire',
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizRandomScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, String category) {
    String? tempSelected;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Choose Difficulty'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Easy'),
                    value: 'Easy',
                    groupValue: tempSelected,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempSelected = val;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Medium'),
                    value: 'Medium',
                    groupValue: tempSelected,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempSelected = val;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Hard'),
                    value: 'Hard',
                    groupValue: tempSelected,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempSelected = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Validate'),
                  onPressed: () {
                    final String? chosenDifficulty =
                        (tempSelected == '' ? null : tempSelected);
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => CategoriesScreen(
                              category: category,
                              initialDifficulty: chosenDifficulty,
                            ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatCategoryTitle(String raw) {
    // Si le nom contient un slash, on sépare et on reformate chaque partie
    if (raw.contains('/')) {
      final parts = raw.split('/');
      return parts
          .map(
            (p) =>
                p.substring(0, 1).toUpperCase() + p.substring(1).toLowerCase(),
          )
          .join(' / ');
    }
    return raw.substring(0, 1).toUpperCase() + raw.substring(1).toLowerCase();
  }
}
