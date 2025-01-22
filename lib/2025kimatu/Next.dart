import 'package:flutter/material.dart';
import 'package:flutter_application_1/2025kimatu/Home.dart';

class Next extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("ページ(1)")),
        body: Center(
          child: TextButton(
            child: Text("Homeページへ"),
            // （1） 前の画面に戻る
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      // （2） 実際に表示するページ(ウィジェット)を指定する
                      builder: (context) => Home()));
            },
          ),
        ));
  }
}
