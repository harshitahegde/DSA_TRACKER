// lib/models/question.dart (FINAL CODE with Review Flag)

class Question {
  final String id;
  final String title;
  final String platform;
  final String topic;
  final String difficulty;
  final String link;   
  final String notes;  
  final String codeSnippet; 
  bool isSolved;
  bool isFlagged; // NEW: Flag for review/struggled
  DateTime? dateSolved; 

  Question({
    required this.id,
    required this.title,
    required this.platform,
    required this.topic,
    required this.difficulty,
    required this.link,    
    required this.notes,   
    required this.codeSnippet, 
    this.isSolved = false,
    this.isFlagged = false, // Default is false
    this.dateSolved,
  });

  // Method to convert a Question object to a Map (JSON format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'topic': topic,
      'difficulty': difficulty,
      'link': link,
      'notes': notes,
      'codeSnippet': codeSnippet,
      'isSolved': isSolved,
      'isFlagged': isFlagged, // ADDED
      'dateSolved': dateSolved?.toIso8601String(), 
    };
  }

  // Factory constructor to create a Question object from a Map (JSON format)
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      platform: json['platform'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      link: json['link'] as String? ?? '', 
      notes: json['notes'] as String? ?? '', 
      codeSnippet: json['codeSnippet'] as String? ?? '', 
      isSolved: json['isSolved'] as bool,
      // Handle missing isFlagged from old data
      isFlagged: json['isFlagged'] as bool? ?? false, 
      dateSolved: json['dateSolved'] != null
          ? DateTime.tryParse(json['dateSolved'] as String)
          : null,
    );
  }

  // Updates solved status and sets the date
  void toggleSolved() {
    isSolved = !isSolved;
    if (isSolved) {
      dateSolved = DateTime.now();
    } else {
      dateSolved = null;
    }
  }
  
  // NEW: Toggle flag status
  void toggleFlagged() {
    isFlagged = !isFlagged;
  }
}