# Quiz Mania

Quiz Mania est une application Flutter de quiz qui récupère des questions depuis l’API QuizMania (hébergée sur RapidAPI). Les utilisateurs peuvent naviguer par catégories, choisir un niveau de difficulté ou lancer un quiz totalement aléatoire.

---

## Configuration du fichier d’environnement

Avant de lancer l’application, il est nécessaire de créer un fichier `.env` à la racine du projet. Ce fichier doit contenir :

```bash
RAPIDAPI_KEY=your_rapidapi_key_here
BASE_URL=https://quizmania-api.p.rapidapi.com
```

- RAPIDAPI_KEY : votre clé API Rapide (fourni par RapidAPI lors de l’abonnement à l’API QuizMania).

- BASE_URL : l’URL de base de l’API QuizMania. Cette valeur doit rester https://quizmania-api.p.rapidapi.com.

---

## Installation et lancement

1. Cloner le dépôt :

```bash
git clone https://github.com/aminemn14/tp-flutter.git
cd quiz-mania
```

2. Installer les dépendances :

```bash
flutter pub get
```

3. Exécuter l’application :

```bash
fluter run
```

---

## Structure du projet

- **env.dart** : Charge et expose les variables d’environnement (RAPIDAPI_KEY et BASE_URL).

- **main.dart** : Initialise les variables d’environnement et démarre l’application.

- **models/question.dart** : Modèle de données pour représenter une question de trivia.

- **services/api_service.dart** : Contient toutes les fonctions pour interagir avec l’API QuizMania (récupération aléatoire, par catégorie, par difficulté, etc.).

- **screens/**

  - **welcome_screen.dart** : écran d’accueil avec le nom de l'app et bouton “Start”.
  - **home_screen.dart** : écran principal listant les catégories et proposant le quiz aléatoire.
  - **quiz_random_screen.dart** : quiz composé de 10 questions aléatoires.
  - **quiz_screen.dart** : quiz filtré par catégorie et difficulté.

- **widgets/**

  - **category_tile.dart** : vignette pour afficher une catégorie (image + nom).
  - **difficulty_filter.dart** : modal pour sélectionner la difficulté (Easy, Medium, Hard).

- **assets/images/categories/** : Contient les images illustrant chaque catégorie (nommage automatique à partir du titre, ex. science.jpg, art.jpg, etc.).

---

Projet réalisé par [Amine Moumen](https://github.com/aminemn14) et [Mathys Dezitter](https://github.com/MathysD-LSN)
