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
      appBar: AppBar(title: Text('学習アシスタントアプリ')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴ
            FlutterLogo(size: 80),
            SizedBox(height: 40),
            // Googleログインボタン
            SizedBox(
              width: double.infinity,
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
            if (_loading) CircularProgressIndicator(),
            SizedBox(height: 40),
            // 利用規約リンク
            TextButton(
              onPressed: () {
                // 利用規約ページへ遷移
              },
              child: Text('利用規約・プライバシーポリシー'),
            ),
          ],
        ),
      ),
    );
  }
}
