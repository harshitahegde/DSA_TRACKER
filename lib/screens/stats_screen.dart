import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
// Note: flutter_local_notifications is generally not needed if using a mock/placeholder function
// However, keeping the import for conceptual completeness.
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 
import '../models/question.dart'; 
import '../widgets/glass_container.dart'; 

// Mock instance for compilation safety
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class StatsScreen extends StatefulWidget {
  // Stats screen must receive the full list of questions to calculate stats
  final List<Question> questions;

  const StatsScreen(this.questions, {super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Default target date is 90 days from now
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));

  // --- NOTIFICATION LOGIC (Mocked for single file context) ---
  Future<void> _scheduleDailyReminder() async {
    // This is a placeholder for actual notification scheduling.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily reminder simulated: Reminder set for 8:00 PM! (Requires package setup)'),
          duration: Duration(seconds: 4),
        )
      );
    }
  }

  // --- DATE PICKER LOGIC ---
  void _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        // Custom theme for the date picker for better dark mode aesthetics
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              // Use secondary color for primary elements (header, selected day)
              primary: Theme.of(context).colorScheme.secondary, 
              onPrimary: Colors.black, // Text color on primary background
              surface: Theme.of(context).primaryColor, // Background of the picker dialog
              onSurface: Colors.white, // Text color on surface
            ),
            dialogBackgroundColor: Theme.of(context).primaryColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  // Helper for generating Pie Chart sections (Difficulty breakdown of SOLVED questions)
  List<PieChartSectionData> _showingSections(int totalSolved) {
    if (totalSolved == 0) {
      // Show a grey slice if no questions are solved
      return [
        PieChartSectionData(
          color: Colors.grey.shade700,
          value: 100,
          title: '0%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }
    
    // Count solved questions by difficulty
    final solvedByDifficulty = widget.questions.where((q) => q.isSolved).fold<Map<String, int>>({}, (map, question) {
      map[question.difficulty] = (map[question.difficulty] ?? 0) + 1;
      return map;
    });

    // Helper function to calculate percentage value
    double getPercentage(String key) => ((solvedByDifficulty[key] ?? 0) / totalSolved) * 100;
    
    // Create sections only for difficulties that have been solved at least once
    return [
      if (solvedByDifficulty.containsKey('Easy') && solvedByDifficulty['Easy']! > 0)
        PieChartSectionData(
          color: Colors.green.shade400,
          value: getPercentage('Easy'),
          title: '${getPercentage('Easy').toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (solvedByDifficulty.containsKey('Medium') && solvedByDifficulty['Medium']! > 0)
        PieChartSectionData(
          color: Colors.blue.shade400,
          value: getPercentage('Medium'),
          title: '${getPercentage('Medium').toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (solvedByDifficulty.containsKey('Hard') && solvedByDifficulty['Hard']! > 0)
        PieChartSectionData(
          color: Colors.red.shade400,
          value: getPercentage('Hard'),
          title: '${getPercentage('Hard').toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
  }

  // --- Recommendation Logic (Weakest Topic: highest number of unsolved problems) ---
  String _getWeakestTopic() {
    if (widget.questions.isEmpty) {
      return 'Start adding questions to get recommendations.';
    }
    if (widget.questions.every((q) => q.isSolved)) {
      return 'Great job! All problems solved.';
    }
    
    // Count unsolved problems per topic
    final unsolvedByTopic = widget.questions.where((q) => !q.isSolved).fold<Map<String, int>>({}, (map, question) {
      // Handle multi-topic entries (e.g., 'Arrays/Hash Maps')
      final topics = question.topic.split('/').map((e) => e.trim()).toList();
      for (var topic in topics) {
        map[topic] = (map[topic] ?? 0) + 1;
      }
      return map;
    });

    String weakestTopic = 'N/A';
    int maxUnsolved = -1;

    // Find the topic with the highest count of unsolved problems
    unsolvedByTopic.forEach((topic, count) {
      if (count > maxUnsolved) {
        maxUnsolved = count;
        weakestTopic = topic;
      }
    });

    return weakestTopic;
  }

  // Helper widget for the Pie Chart legend
  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final solvedQuestions = widget.questions.where((q) => q.isSolved).toList();
    final unsolvedQuestions = widget.questions.where((q) => !q.isSolved).toList();
    final totalSolved = solvedQuestions.length;
    final totalUnsolved = unsolvedQuestions.length;
    final totalQuestions = widget.questions.length;
    
    // Goal Calculation
    final daysRemaining = _targetDate.difference(DateTime.now()).inDays + 1;
    final dailyTarget = daysRemaining > 0 ? (totalUnsolved / daysRemaining) : totalUnsolved.toDouble();
    final dailyTargetDisplay = dailyTarget.ceil();
    final weakestTopic = _getWeakestTopic();

    // Top Solved Topics
    final solvedByTopic = solvedQuestions.fold<Map<String, int>>({}, (map, question) {
      final topics = question.topic.split('/').map((e) => e.trim()).toList();
      for (var topic in topics) {
        map[topic] = (map[topic] ?? 0) + 1;
      }
      return map;
    });
    
    // Sort descending by solved count
    final topTopics = solvedByTopic.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Overall Progress Card
          GlassContainer(
            // Use cardColor/surface for better glass effect contrast
            backgroundColor: theme.cardColor.withOpacity(0.5), 
            elevation: 10,
            child: Column(
              children: [
                Text('Overall Progress', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
                const SizedBox(height: 15),
                Text(
                  '$totalSolved / $totalQuestions Solved', 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                // Progress Bar
                LinearProgressIndicator(
                  value: totalQuestions > 0 ? totalSolved / totalQuestions : 0,
                  backgroundColor: Colors.grey.shade700,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 5),
                Text(
                  '$totalUnsolved Remaining', 
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 2. Difficulty Pie Chart
          GlassContainer(
            backgroundColor: theme.cardColor.withOpacity(0.5),
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solved Difficulty Distribution', 
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: _showingSections(totalSolved),
                          ),
                        ),
                      ),
                      // Legend
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Legends are now only for the slices that appear in the chart
                          _buildLegend(Colors.green.shade400, 'Easy Solved'),
                          _buildLegend(Colors.blue.shade400, 'Medium Solved'),
                          _buildLegend(Colors.red.shade400, 'Hard Solved'),
                          if (totalSolved == 0)
                            _buildLegend(Colors.grey.shade700, 'No Solved Data'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 3. Goal Setting Card & Reminder
          GlassContainer(
            backgroundColor: theme.colorScheme.tertiary.withOpacity(0.7), // Use Tertiary for Goal/Action
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goal Setting & Daily Targets', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const Divider(color: Colors.white54),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Target Date:', style: TextStyle(fontSize: 16, color: Colors.white)),
                    // Button to select a new target date
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                      label: Text(DateFormat.yMMMd().format(_targetDate), style: const TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: _selectTargetDate,
                    ),
                  ],
                ),
                Text('Days Remaining: $daysRemaining', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 15),
                Text('Daily Target: $dailyTargetDisplay Qs/Day', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.secondary)),
                
                const SizedBox(height: 15),
                // Daily Reminder Button
                ElevatedButton.icon(
                  onPressed: _scheduleDailyReminder,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Set Daily 8 PM Reminder'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: theme.colorScheme.secondary,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 4. Recommendation Card (Weakest Topic)
          GlassContainer(
            backgroundColor: Colors.black.withOpacity(0.7),
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎯 Recommendation: Focus Area', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                const Divider(color: Colors.white38),
                const Text('Your current analysis suggests focusing on:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text(weakestTopic, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.redAccent)),
                const SizedBox(height: 5),
                Text(
                  // Show explanatory text only if a real topic is identified
                  weakestTopic.contains('N/A') || weakestTopic.contains('Start adding') || weakestTopic.contains('Great job')
                  ? '' 
                  : '(Based on having the highest number of unsolved problems.)', 
                  style: const TextStyle(color: Colors.white54, fontSize: 12)
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          // 5. Top Topics Breakdown 
          Text('Top Solved Topics:', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const Divider(color: Colors.white54),
          // Fallback if no questions are solved
          if (topTopics.isEmpty)
             const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Start solving problems to see your top performing topics!",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
             )
          else
            ...topTopics.take(5).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassContainer(
                blur: 5,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                backgroundColor: theme.cardColor.withOpacity(0.5),
                elevation: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 18, color: Colors.white)),
                    Text('${entry.value}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  ],
                ),
              ),
            )).toList(),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
