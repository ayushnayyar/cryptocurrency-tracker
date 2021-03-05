import 'package:flutter/material.dart';
import 'package:cryptocurrency_tracker/screens/chat_screen.dart';
import 'package:cryptocurrency_tracker/screens/settings_screen.dart';
import 'package:cryptocurrency_tracker/screens/tracker_screen.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Currency Tracker',
      initialRoute: ChatScreen.id,
      routes: {
        ChatScreen.id: (context) => ChatScreen(),
        'tracker_screen': (context) => TrackerScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
      },
    );
  }
}
