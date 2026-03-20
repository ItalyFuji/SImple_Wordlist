import 'package:flutter/material.dart';

// ④ 出題設定画面（仮）
// あとで実装する
class SettingsScreen extends StatelessWidget {
  final String language;
  final List<String> categories;

  const SettingsScreen({
    super.key,
    required this.language,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language)),
      body: Center(child: Text('出題設定画面（工事中）\n選択品詞: $categories')),
    );
  }
}
