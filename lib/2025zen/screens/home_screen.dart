import 'package:flutter/material.dart';
import 'package:flutter_application_1/2025zen/firebase/auth_service.dart'; // AuthServiceをインポート
import 'package:flutter_application_1/2025zen/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ホーム")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ログイン成功！'),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('ログアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
