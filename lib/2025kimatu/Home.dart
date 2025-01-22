import 'package:flutter/material.dart';
import 'package:flutter_application_1/2025kimatu/Next.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ホーム"),
      ),
      body: Center(
        child: TextButton(
          child: Text("Nextページへ"),
          onPressed: () {
            // （1） 指定した画面に遷移する
            Navigator.push(
                context,
                MaterialPageRoute(
                    // （2） 実際に表示するページ(ウィジェット)を指定する
                    builder: (context) => Next()));
          },
        ),
      ),
    );
  }
}
