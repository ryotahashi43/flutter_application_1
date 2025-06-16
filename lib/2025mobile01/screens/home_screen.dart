import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'memo_page.dart';
import 'calendar_page.dart';
import 'progress_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ChatPage(),
    MemoPage(),
    CalendarPage(),
    ProgressPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'チャット'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'メモ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '進捗'),
        ],
      ),
    );
  }
}
