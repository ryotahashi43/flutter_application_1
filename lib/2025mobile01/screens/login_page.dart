import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarを非表示にして、自由なレイアウトを実現
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),

      // CenterでColumn全体を中央に配置
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // ← 横方向も中央揃え
            children: [
              // タイトル
              Text(
                '学習アシスタントアプリ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Flutterロゴ（任意で変更可能）
              FlutterLogo(size: 80),
              SizedBox(height: 40),

              // Googleログインボタン（幅を調整）
              SizedBox(
                width: 300, // ← ボタンの横幅を指定
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/geegte_logo.png',
                    height: 24,
                  ),
                  label: Text('Googleでログイン'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          final user = await _authService.signInWithGoogle();
                          setState(() => _loading = false);
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                            );
                          }
                        },
                ),
              ),
              SizedBox(height: 20),

              // ローディングインジケーター
              if (_loading) ...[
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('ログイン中...', style: TextStyle(fontSize: 14)),
              ],

              SizedBox(height: 40),

              // 利用規約リンク
              TextButton(
                onPressed: () {
                  // TODO: 利用規約ページへの遷移処理を追加
                },
                child: Text('利用規約・プライバシーポリシー'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
