// lib/models/dummy_data.dart (FINAL CODE)

import 'question.dart'; // Changed to relative import

// Temporary list of questions to display on the Home Screen on first run
List<Question> DUMMY_QUESTIONS = [
  Question(
    id: 'q1',
    title: 'Two Sum',
    platform: 'LeetCode',
    topic: 'Arrays',
    difficulty: 'Easy',
    isSolved: true,
    // FIX: Added required parameter isFlagged
    isFlagged: false,
    dateSolved: DateTime(2025, 1, 15), link: '', notes: '', codeSnippet: '',
  ),
  Question(
    id: 'q2',
    title: 'Longest Palindromic Substring',
    platform: 'LeetCode',
    topic: 'Strings/DP',
    difficulty: 'Medium',
    isSolved: false, 
    // FIX: Added required parameter isFlagged
    isFlagged: true, // Example of a flagged question
    link: '', notes: '', codeSnippet: '',
  ),
  Question(
    id: 'q3',
    title: 'Kth Smallest Element in a BST',
    platform: 'GFG',
    topic: 'Trees/BST',
    difficulty: 'Medium',
    isSolved: true,
    // FIX: Added required parameter isFlagged
    isFlagged: false,
    dateSolved: DateTime(2025, 1, 28), link: '', notes: '', codeSnippet: '',
  ),
  Question(
    id: 'q4',
    title: 'N-Queens',
    platform: 'LeetCode',
    topic: 'Backtracking',
    difficulty: 'Hard',
    isSolved: false, 
    // FIX: Added required parameter isFlagged
    isFlagged: false,
    link: '', notes: '', codeSnippet: '',
  ),
];
