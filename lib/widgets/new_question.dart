import 'package:flutter/material.dart';

class NewQuestion extends StatefulWidget {
  final Function addQuestion;

  const NewQuestion(this.addQuestion, {super.key});

  @override
  State<NewQuestion> createState() => _NewQuestionState();
}

class _NewQuestionState extends State<NewQuestion> {
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _platformController = TextEditingController();
  final _linkController = TextEditingController();
  final _notesController = TextEditingController(); 
  final _codeController = TextEditingController(); // NEW CONTROLLER
  
  String _selectedDifficulty = 'Easy'; 
  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _platformController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    _codeController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredTopic = _topicController.text;
    final enteredPlatform = _platformController.text;
    final enteredLink = _linkController.text;
    final enteredNotes = _notesController.text;
    final enteredCode = _codeController.text; // NEW VALUE
    
    // Simple validation for required fields
    if (enteredTitle.isEmpty || enteredTopic.isEmpty) {
      return; 
    }

    widget.addQuestion(
      enteredTitle,
      enteredTopic,
      _selectedDifficulty,
      enteredPlatform,
      enteredLink,
      enteredNotes,
      enteredCode, // PASS NEW VALUE
    );

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 15,
          right: 15,
          // Adjust padding dynamically for the keyboard
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          // Using colorScheme.surface instead of deprecated cardColor
          color: theme.colorScheme.surface.withOpacity(0.95), 
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min, 
          children: <Widget>[
            Text('Add New Question', style: theme.textTheme.headlineSmall),
            const Divider(),
            
            // Title Input
            TextField(
              decoration: const InputDecoration(labelText: 'Question Title *', prefixIcon: Icon(Icons.title)),
              controller: _titleController,
            ),
            // Topic Input
            TextField(
              decoration: const InputDecoration(labelText: 'Topic (e.g., Arrays, DP) *', prefixIcon: Icon(Icons.category)),
              controller: _topicController,
            ),
            // Link Input
            TextField(
              decoration: const InputDecoration(labelText: 'Question Link (Optional)', prefixIcon: Icon(Icons.link)),
              controller: _linkController,
            ),
            // Platform Input
            TextField(
              decoration: const InputDecoration(labelText: 'Platform (e.g., LeetCode)', prefixIcon: Icon(Icons.laptop_chromebook)),
              controller: _platformController,
            ),
            
            // Difficulty Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDifficulty,
                decoration: InputDecoration(
                  labelText: 'Difficulty',
                  prefixIcon: const Icon(Icons.align_horizontal_left),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                items: _difficultyOptions.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() { _selectedDifficulty = newValue; });
                  }
                },
              ),
            ),
            
            // Notes Input
            TextField(
              decoration: const InputDecoration(labelText: 'Notes/Solution Overview', prefixIcon: Icon(Icons.edit_note)),
              controller: _notesController,
              maxLines: 3,
            ),
            
            // Code Snippet Input (NEW)
            TextField(
              decoration: const InputDecoration(labelText: 'Code Snippet (Final Solution)', prefixIcon: Icon(Icons.code)),
              controller: _codeController,
              maxLines: 5,
            ),

            // Submit Button
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
