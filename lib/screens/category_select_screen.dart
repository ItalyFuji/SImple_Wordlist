import 'package:flutter/material.dart';

// ③ 品詞選択画面（仮）
// あとで実装する
class CategorySelectScreen extends StatelessWidget {
  final String language; // 前の画面から受け取る言語名

  const CategorySelectScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language)),
      // 仮の表示（あとで実装）
      body: const Center(child: Text('品詞選択画面（工事中）')),
    );
  }
}
