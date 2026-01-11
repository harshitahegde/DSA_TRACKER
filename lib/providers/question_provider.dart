// lib/providers/question_provider.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';
import '../models/dummy_data.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];
  static const String _storageKey = 'dsa_questions';

  List<Question> get questions => [..._questions];

  // --- Persistence Logic ---

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsString = prefs.getString(_storageKey);

    if (questionsString != null) {
      try {
        final List<dynamic> questionsList = jsonDecode(questionsString);
        _questions = questionsList.map((item) => Question.fromJson(item)).toList();
      } catch (e) {
        // Handle corrupted data by loading dummy data
        _questions = DUMMY_QUESTIONS;
        _saveData(); 
      }
    } else {
      _questions = DUMMY_QUESTIONS;
      _saveData();
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> questionsMapList = 
        _questions.map((q) => q.toJson()).toList();
    final String questionsString = jsonEncode(questionsMapList);
    await prefs.setString(_storageKey, questionsString);
  }

  // --- CRUD/Update Methods ---

  void addNewQuestion(String title, String topic, String difficulty, String platform, String link, String notes, String codeSnippet) {
    final newQuestion = Question(
      id: DateTime.now().toString(), 
      title: title,
      platform: platform,
      topic: topic,
      difficulty: difficulty,
      link: link,
      notes: notes,
      codeSnippet: codeSnippet, 
      isSolved: false, 
      isFlagged: false, // Default is not flagged
    );
    _questions.add(newQuestion);
    _saveData();
    notifyListeners();
  }

  void deleteQuestion(String id) {
    _questions.removeWhere((q) => q.id == id);
    _saveData();
    notifyListeners();
  }
  
  void toggleSolved(String id) {
    final questionIndex = _questions.indexWhere((q) => q.id == id);
    if (questionIndex >= 0) {
      _questions[questionIndex].toggleSolved(); 
      _saveData();
      notifyListeners();
    }
  }
  
  void toggleFlagged(String id) {
    final questionIndex = _questions.indexWhere((q) => q.id == id);
    if (questionIndex >= 0) {
      _questions[questionIndex].toggleFlagged(); 
      _saveData();
      notifyListeners();
    }
  }
  
  // --- Recommendation Logic ---
  
  // Gets the top 3 topics that the user has solved the least of
  List<String> getWeakestTopics() {
    if (_questions.isEmpty) return ['Arrays', 'Strings', 'DP'];

    final Map<String, int> topicCounts = {};
    for (var q in _questions) {
      // Split topic string by '/' and count occurrences
      final topics = q.topic.split('/').map((e) => e.trim()).toList();
      for (var topic in topics) {
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }
    }

    // Identify topics with the fewest solved questions
    final solvedCounts = _questions.where((q) => q.isSolved).fold<Map<String, int>>({}, (map, question) {
      final topics = question.topic.split('/').map((e) => e.trim()).toList();
      for (var topic in topics) {
        map[topic] = (map[topic] ?? 0) + 1;
      }
      return map;
    });

    final List<MapEntry<String, int>> weakestTopics = solvedCounts.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value)); // Sort ascending by solved count

    // Return the top 3 weakest topics
    return weakestTopics.take(3).map((e) => e.key).toList();
  }
}