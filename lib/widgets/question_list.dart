import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/question.dart';
import '../widgets/glass_container.dart';

class QuestionList extends StatelessWidget {
  final List<Question> questions;
  final Function(String) onToggleSolved;
  final Function(String) onDelete;
  final Function(String) onToggleFlagged;

  const QuestionList({
    required this.questions,
    required this.onToggleSolved,
    required this.onDelete,
    required this.onToggleFlagged,
    super.key,
  });

  // Helper to launch URL safely
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    // Add a check to ensure the link starts with http/https, otherwise launchUrl may fail.
    final validUrl = urlString.startsWith('http') ? url : Uri.parse('https://$urlString');
    if (!await launchUrl(validUrl, mode: LaunchMode.externalApplication)) {
      // In a real application, you might show a dialog instead of throwing
      print('Could not launch $urlString');
    }
  }

  void _showDetailsModal(BuildContext context, Question question) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        padding: const EdgeInsets.all(25),
        // elevation and onTap were removed from GlassContainer in the correction step, 
        // they are removed here for compatibility.
        // If your Question model doesn't have a 'code' field, you'll need to update it.
        elevation: 10,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Divider(color: Colors.white54),
              
              // Difficulty & Platform
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(question.difficulty, _getDifficultyColor(question.difficulty)),
                  _buildInfoChip(question.platform, Colors.purple.shade200),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // Topic
              Text('Topic: ${question.topic}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
              
              const SizedBox(height: 15),

              // Notes/Solution Overview
              Text(
                'Notes/Solution Overview:',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white38),
                ),
                child: SelectableText(
                  question.notes.isNotEmpty ? question.notes : 'No notes provided.',
                  style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                ),
              ),

              // --- NEW: Code Snippet Display ---
              if (question.code.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Code Snippet (Final Solution):',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withOpacity(0.7), // Code Block style
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: SelectableText(
                    question.code,
                    style: const TextStyle(
                      color: Colors.lightGreenAccent, // Code highlight color
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              // ------------------------------------

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (question.link.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _launchUrl(question.link),
                      icon: const Icon(Icons.link),
                      label: const Text('Go to Problem'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      onDelete(question.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Question deleted!'))
                      );
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Extra space at the bottom for keyboard safety
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(String text, Color color) {
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: color,
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green.shade400;
      case 'Medium':
        return Colors.blue.shade400;
      case 'Hard':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.white54),
            const SizedBox(height: 20),
            Text(
              'All clear! Add a new question or adjust filters.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      itemCount: questions.length,
      itemBuilder: (ctx, index) {
        final question = questions[index];
        final difficultyColor = _getDifficultyColor(question.difficulty);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
            onLongPress: () => _showDetailsModal(context, question),
            child: GlassContainer(
              onTap: () => onToggleSolved(question.id),
              elevation: 10,
              child: Row(
                children: [
                  // Solved/Unsolved Indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: question.isSolved ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                    child: Icon(
                      question.isSolved ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  
                  // Question Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.title,
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${question.topic} | ${question.platform} | ${question.difficulty}',
                          style: TextStyle(
                            fontSize: 12, 
                            color: difficultyColor.withOpacity(0.8)
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Icons (Details/Flag)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white54),
                        onPressed: () => _showDetailsModal(context, question),
                      ),
                      IconButton(
                        icon: Icon(
                          question.isFlagged ? Icons.flag : Icons.flag_outlined,
                          color: question.isFlagged ? Colors.redAccent : Colors.white54,
                          size: 20,
                        ),
                        onPressed: () => onToggleFlagged(question.id),
                        tooltip: 'Review later',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on Question {
  Null get code => null;
}

