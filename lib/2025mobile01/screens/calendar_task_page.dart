import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTaskPage extends StatefulWidget {
  @override
  State<CalendarTaskPage> createState() => _CalendarTaskPageState();
}

class _CalendarTaskPageState extends State<CalendarTaskPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStr =
        _selectedDay != null ? _formatDate(_selectedDay!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('タスク・予定カレンダー'),
        actions: [
          if (_selectedDay != null)
            IconButton(
              icon: Icon(Icons.add),
              tooltip: '予定を追加',
              onPressed: () => _showAddScheduleDialog(),
            ),
        ],
      ),
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
          SizedBox(height: 8),
          if (_selectedDay == null)
            Expanded(child: Center(child: Text('日付を選択してください')))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSectionTitle('■ タスク'),
                    _buildTaskList(_formatDate(_selectedDay!)),
                    _buildSectionTitle('■ 予定'),
                    _buildScheduleList(_formatDate(_selectedDay!)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTaskList(String selectedDateStr) {
    DateTime selectedDate = DateTime.parse(selectedDateStr);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('startDate', isLessThanOrEqualTo: selectedDateStr)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final start = data['startDate'];
          final end = data['endDate'];

          if (start == null || end == null) return false;

          try {
            final startDate = DateTime.parse(start);
            final endDate = DateTime.parse(end);
            return selectedDate.isAtSameMomentAs(startDate) ||
                selectedDate.isAtSameMomentAs(endDate) ||
                (selectedDate.isAfter(startDate) &&
                    selectedDate.isBefore(endDate));
          } catch (_) {
            return false;
          }
        }).toList();

        if (docs.isEmpty) return Center(child: Text('この日のタスクはありません'));

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? '未着手';
            Color tileColor;
            switch (status) {
              case '進行中':
                tileColor = Colors.blue[100]!;
                break;
              case '完了':
                tileColor = Colors.green[100]!;
                break;
              default:
                tileColor = Colors.grey[300]!;
            }

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('進捗: ${data['progress'] ?? 0}%'),
                    Text('ステータス: $status'),
                  ],
                ),
                onTap: () => _showEditTaskDialog(docs[index].id, data),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleList(String date) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .where('date', isEqualTo: date)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text('この日の予定はありません'));

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['memo'] ?? ''),
                onTap: () => _showEditScheduleDialog(docs[index].id, data),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final progress = (data['progress'] ?? 0).toDouble();
    String status = data['status'] ?? '未着手';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('タスク編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'タイトル'),
              ),
              SizedBox(height: 8),
              Text('進捗: ${progress.round()}%'),
              Slider(
                value: progress,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${progress.round()}%',
                onChanged: (value) => setState(() => data['progress'] = value),
              ),
              DropdownButton<String>(
                value: status,
                onChanged: (value) {
                  if (value != null) setState(() => status = value);
                },
                items: ['未着手', '進行中', '完了']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('tasks')
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
                final newTitle = titleController.text.trim();
                if (newTitle.isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('tasks')
                    .doc(docId)
                    .update({
                  'title': newTitle,
                  'progress': data['progress'].round(),
                  'status': status,
                });
                Navigator.pop(context);
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditScheduleDialog(String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final memoController = TextEditingController(text: data['memo'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('予定編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'タイトル')),
            TextField(
                controller: memoController,
                decoration: InputDecoration(labelText: 'メモ')),
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
              onPressed: () => Navigator.pop(context), child: Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newMemo = memoController.text.trim();
              if (newTitle.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('schedules')
                  .doc(docId)
                  .update({
                'title': newTitle,
                'memo': newMemo,
              });
              Navigator.pop(context);
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final memoController = TextEditingController();
    final selectedDateStr = _formatDate(_selectedDay!);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$selectedDateStr の予定を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'タイトル')),
            TextField(
                controller: memoController,
                decoration: InputDecoration(labelText: 'メモ（任意）')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final memo = memoController.text.trim();
              if (title.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('schedules')
                  .add({
                'title': title,
                'memo': memo,
                'date': selectedDateStr,
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
