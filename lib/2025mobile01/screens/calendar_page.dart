import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('カレンダー')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            locale: 'ja_JP',
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            _selectedDay != null
                ? '選択した日付: ${_selectedDay!.toLocal().toString().split(' ')[0]}'
                : '日付を選択してください',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay == null) return;
          _showAddEventDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog() {
    final _titleController = TextEditingController();
    final _memoController = TextEditingController();
    final selectedDateStr =
        _selectedDay!.toLocal().toString().split(' ')[0]; // yyyy-MM-dd

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$selectedDateStr の予定を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(labelText: 'メモ（任意）'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final memo = _memoController.text.trim();

              if (title.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('schedules')
                  .add({
                'date': selectedDateStr,
                'title': title,
                'memo': memo,
                'timestamp': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: Text('追加'),
          ),
        ],
      ),
    );
  }
}
