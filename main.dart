// ignore: unused_import
import 'package:dsa_tracker/screens/home_page.dart' hide TimerScreen;
import 'package:flutter/material.dart';
// Note: In a fully complete app, you would also need to import:
// import '../providers/question_provider.dart';
// import '../widgets/question_list.dart';
// import 'stats_screen.dart';

import 'package:dsa_tracker/screens/timer_screen.dart';

/// The main container for the application, handling tab navigation.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State to track the currently selected tab index
  int _selectedPageIndex = 1; 

  // List of pages to display in the body
  final List<Widget> pages = [
    // Page 0: Tasks List (Placeholder)
    const Center(child: Text('Tasks List (Requires QuestionList and Provider)', style: TextStyle(fontSize: 20, color: Colors.grey))),
    
    // Page 1: Focus Timer (The TimerScreen implementation)
    
    const TimerScreen(),
    
    // Page 2: Stats Screen (Placeholder)
    const Center(child: Text('Statistics Screen (Requires StatsScreen)', style: TextStyle(fontSize: 20, color: Colors.grey))),
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // The body displays the currently selected page
      body: pages[_selectedPageIndex],
      
      // Floating Action Button is removed here to keep it simple, 
      // but you can add it back on the Tasks screen (Page 0)
      
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        
        // Styling based on the primary color defined in main.dart
        backgroundColor: theme.primaryColor.withOpacity(0.95),
        unselectedItemColor: Colors.white70,
        selectedItemColor: theme.colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Focus'), 
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
