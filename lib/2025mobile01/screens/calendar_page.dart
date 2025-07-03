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

  String _formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0]; // yyyy-MM-dd
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStr =
        _selectedDay != null ? _formatDate(_selectedDay!) : null;

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
          if (_selectedDay != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('schedules')
                    .where('date', isEqualTo: selectedDateStr)
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(child: Text('予定はありません'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      return ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(data['memo'] ?? ''),
                        onTap: () {
                          _showEditEventDialog(
                              data.id, data['title'], data['memo']);
                        },
                      );
                    },
                  );
                },
              ),
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
    final selectedDateStr = _formatDate(_selectedDay!);

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

  void _showEditEventDialog(String docId, String oldTitle, String oldMemo) {
    final _titleController = TextEditingController(text: oldTitle);
    final _memoController = TextEditingController(text: oldMemo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('予定を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(labelText: 'メモ'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('schedules')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: Text('削除', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = _titleController.text.trim();
              final newMemo = _memoController.text.trim();

              if (newTitle.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('schedules')
                  .doc(docId)
                  .update({
                'title': newTitle,
                'memo': newMemo,
                'timestamp': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }
}
