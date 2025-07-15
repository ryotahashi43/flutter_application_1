import 'package:flutter/material.dart';

class StartGuidePage extends StatelessWidget {
  const StartGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アプリの使い方'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _sectionTitle('📌 アプリの目的'),
          Text(
            'このアプリは、学習を効率化し、日々の進捗を管理するための学習アシスタントです。\nAIとのチャット、メモ、予定・タスク管理などを通じて、継続的な学びをサポートします。',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 24),
          _sectionTitle('💬 チャット機能'),
          Text(
            'Gemini AI に質問して学習サポートを受けられます。\n・質問を入力して送信\n・AIの返答は時刻＆日付付きで表示\n・会話は自動保存されます',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 24),
          _sectionTitle('📝 メモ機能'),
          Text(
            '学んだことや気づいたことを自由に記録できます。\n・新規メモの作成、一覧表示、編集・削除が可能\n・保存時刻も確認できます',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 24),
          _sectionTitle('📅 カレンダー機能'),
          Text(
            'タスクや予定を日付ごとに一覧で表示できます。\n・タスクと予定（schedules）が両方反映\n・ステータスごとに色分け\n・タップして編集や削除も可能',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 24),
          _sectionTitle('📊 進捗管理'),
          Text(
            '各タスクの進捗度（％）を記録・確認できます。\n・進行中・完了などのステータス切り替え\n・進捗バーで視覚的に管理',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 24),
          _sectionTitle('🔐 ログイン・ログアウト'),
          Text(
            'Google アカウントでログインして利用します。\n・AppBarの右上ボタンからログアウトできます\n・ログアウト後は再ログインが必要です',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }
}
