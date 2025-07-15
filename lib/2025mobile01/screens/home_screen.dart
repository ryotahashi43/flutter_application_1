import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'chat_page.dart';
import 'memo_page.dart';
import 'task_page.dart';
import 'calendar_task_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [
    ChatPage(),
    MemoPage(),
    CalendarTaskPage(),
    TaskPage(),
  ];

  final List<String> _titles = [
    'チャット',
    'メモ',
    'カレンダー',
    '進捗',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('ログアウトしますか？'),
                  content: Text('もう一度ログインする必要があります。'),
                  actions: [
                    TextButton(
                      child: Text('キャンセル'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      child: Text('ログアウト'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              }
            },
          )
        ],
      ),

      // ページ切り替えをIndexedStackでスムーズに
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'チャット'),
          BottomNavigationBarItem(
              icon: Icon(Icons.note_alt_outlined), label: 'メモ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined), label: 'カレンダー'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: '進捗'),
        ],
      ),
    );
  }
}
