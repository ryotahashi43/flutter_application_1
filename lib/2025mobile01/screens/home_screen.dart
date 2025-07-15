import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'chat_page.dart';
import 'memo_page.dart';
import 'task_page.dart';
import 'calendar_task_page.dart';
import 'add_memo_page.dart'; // ← 追加

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

  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue[200],
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: _isLoggingOut
                ? null
                : () async {
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
                      setState(() => _isLoggingOut = true);

                      await _authService.signOut();

                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (route) => false,
                        );
                      }
                    }
                  },
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // メモタブのときだけFABを右下に表示し、AddMemoPageへ遷移
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddMemoPage()),
                );
              },
              child: Icon(Icons.add),
              tooltip: '新規メモ作成',
            )
          : null,
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
