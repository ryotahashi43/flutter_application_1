import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'start_guide.dart';

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

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // タイトル
              Text(
                'Study Helper',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              FlutterLogo(size: 80),
              SizedBox(height: 40),

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

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StartGuidePage()),
                  );
                },
                child: Text('このアプリの使い方'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
