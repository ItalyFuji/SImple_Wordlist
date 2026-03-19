import 'package:flutter/material.dart';

// ① はじめに画面
// アプリを開いたときに最初に表示される画面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold: 画面の基本的な骨格（背景・AppBarなど）を提供するWidget
    return Scaffold(
      // SafeArea: ノッチや画面端のシステムUIと重ならないように余白を確保する
      body: SafeArea(
        // Padding: 内側に余白を作るWidget
        child: Padding(
          padding: const EdgeInsets.all(32.0), // 全方向に32pxの余白
          // Column: 子Widgetを縦に並べるWidget
          child: Column(
            // mainAxisAlignment: 縦方向の並べ方（center = 中央に集める）
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // アプリタイトル
              const Text(
                'Simple Wordlist',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // SizedBox: 空白スペースを作るWidget（height = 縦の高さ）
              const SizedBox(height: 24),

              // アプリの説明文
              const Text(
                'これは私が欲しくて趣味で作ったアプリです。',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center, // テキストを中央揃え
              ),

              const SizedBox(height: 48),

              // 「はじめる」ボタン
              // SizedBox(width: double.infinity) で横幅いっぱいに広げる
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // onPressed: ボタンが押されたときの処理
                  // TODO: あとで言語選択画面への遷移を追加する
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'はじめる',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
