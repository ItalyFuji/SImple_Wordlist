import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'language_select_screen.dart'; // 言語選択画面へ遷移するためにインポート

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

              // アプリの説明文を丸い四角で囲む
              // Container: 大きさ・色・枠線・余白などを自由に設定できる汎用Widget
              Container(
                // padding: Container内側の余白
                padding: const EdgeInsets.all(16),
                // decoration: 見た目の装飾（色・枠線・角丸など）を設定する
                decoration: BoxDecoration(
                  // border: 枠線の設定
                  border: Border.all(
                    color: Colors.grey,  // 枠線の色
                    width: 1,            // 枠線の太さ
                  ),
                  // borderRadius: 角の丸み（数字が大きいほど丸くなる）
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'これは私が欲しくて趣味で作った単語帳アプリです。\n語学学習の一助となれば幸いです。',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                  // locale: 日本語を指定することで句読点の位置が正しくなる
                  locale: const Locale('ja'),
                ),
              ),

              const SizedBox(height: 48),

              // 「はじめる」ボタン
              // Center: 子Widgetを中央に配置する
              // SizedBoxで幅を固定すると左寄りになるため、Centerで囲んで中央揃えにする
              Center(
                child: SizedBox(
                width:  MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  // onPressed: ボタンが押されたときの処理
                  // Navigator.push で言語選択画面に移動する
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSelectScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary, // メインカラー：藤色
                  ),
                  child: const Text(
                    'はじめる',
                    style: TextStyle(fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                ), // SizedBox を閉じる
              ), // Center を閉じる

            ],
          ),
        ),
      ),
    );
  }
}
