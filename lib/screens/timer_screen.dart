import 'package:flutter/material.dart';
import 'dart:async';
// NOTE: flutter_local_notifications import removed to prevent dependency errors.
// The notification function will now purely use debugPrint.

/// A Pomodoro timer screen used for focused study sessions.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key}); 

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Timer settings
  static const int focusDuration = 25 * 60; // 25 minutes in seconds
  static const int breakDuration = 5 * 60; // 5 minutes in seconds

  late Timer _timer = Timer(Duration.zero, () {});
  int _currentSeconds = focusDuration;
  bool _isRunning = false;
  bool _isFocusMode = true; // true = Focus, false = Break
  int _pomodoroCount = 0; // Tracks completed focus sessions

  @override
  void initState() {
    super.initState();
    _currentSeconds = focusDuration;
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  // --- Notification Logic ---
  // Simplified to only use debugPrint to log timer completion events, 
  // avoiding external plugin type dependencies in this file.
  Future<void> _scheduleNotification(String title, String body) async {
    // In a production app, the notification plugin would be passed here or
    // accessed via dependency injection to display a notification.
    debugPrint('Notification scheduled: $title - $body');
  }

  // --- Timer Controls ---
  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        // Timer finished
        _timer.cancel();
        _handleTimerCompletion();
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _currentSeconds = focusDuration;
      _isRunning = false;
      _isFocusMode = true;
      _pomodoroCount = 0;
    });
  }

  void _handleTimerCompletion() {
    if (_isFocusMode) {
      // Focus session ended -> switch to Break
      _pomodoroCount++;
      _scheduleNotification(
        "Time for a Break!", 
        "You completed Pomodoro #$_pomodoroCount. Start your 5-minute break.",
      );
      setState(() {
        _isFocusMode = false;
        _currentSeconds = breakDuration;
      });
    } else {
      // Break session ended -> switch to Focus
      _scheduleNotification(
        "Break is Over!", 
        "Get back to work! Start Pomodoro #${_pomodoroCount + 1}.",
      );
      setState(() {
        _isFocusMode = true;
        _currentSeconds = focusDuration;
      });
    }
    // Automatically start the next phase
    _startTimer();
  }

  // --- Display Helpers ---
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  double _getTimerProgress() {
    final totalDuration = _isFocusMode ? focusDuration : breakDuration;
    return (_currentSeconds / totalDuration);
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayTime = _formatTime(_currentSeconds);
    // Dynamic colors based on mode
    final primaryColor = _isFocusMode ? theme.primaryColor : Colors.green.shade700;
    final secondaryColor = _isFocusMode ? theme.colorScheme.secondary : Colors.lightGreenAccent;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isFocusMode ? 'FOCUS TIME' : 'BREAK TIME',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _isFocusMode ? 'Pomodoro Cycle: #$_pomodoroCount' : 'Get ready for Pomodoro #${_pomodoroCount + 1}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            
            // Circular Timer Display
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _getTimerProgress(),
                    valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                    backgroundColor: primaryColor.withOpacity(0.2),
                    strokeWidth: 15,
                  ),
                  Center(
                    child: Text(
                      displayTime,
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w100,
                        color: primaryColor,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Start / Pause Button
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'PAUSE' : 'START'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                ),
                
                const SizedBox(width: 20),

                // Reset Button
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('RESET'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
