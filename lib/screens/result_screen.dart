import 'package:flutter/material.dart';
import '../models/quiz_session.dart';
import '../utils/app_colors.dart';

// ⑥ リザルト画面
class ResultScreen extends StatelessWidget {
  final QuizSession session;

  const ResultScreen({super.key, required this.session});

  // N回popしてN個前の画面に戻るヘルパー
  // 画面スタック: Home → 言語選択 → 品詞選択 → 出題設定 → リザルト
  // 「言語選択に戻る」→ 3回pop / 「品詞選択に戻る」→ 2回pop / 「出題設定に戻る」→ 1回pop
  void _popTimes(BuildContext context, int times) {
    int count = 0;
    Navigator.popUntil(context, (_) => count++ >= times);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('リザルト画面'),
        // 戻るボタンを非表示にする（リザルト画面からは専用ボタンで戻る）
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [

              // --- お疲れさまでした + スコア ---
              const Text(
                'お疲れさまでした！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // スコア表示
              Text(
                '覚えてた単語数：${session.correctCount}/${session.total}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // --- 出題単語一覧 ---
              // Expanded + ListView で残りスペースをリストが埋める
              Expanded(
                child: ListView.separated(
                  // session.words の各単語を行として表示
                  itemCount: session.words.length,
                  // separatorBuilder: 各行の間に区切り線を入れる
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final word = session.words[index];
                    // results[index]: true=〇(覚えてた) / false=✕(覚えてなかった)
                    final remembered = session.results[index] ?? false;

                    return ListTile(
                      // 単語と意味を表示
                      title: Text(
                        '${word.word}：${word.meaning}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      // 右側に〇か✕を表示
                      trailing: Text(
                        remembered ? '〇' : '✕',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // 〇は緑、✕は赤
                          color: remembered ? Colors.green : Colors.red,
                        ),
                      ),
                      // 行の背景色: 品詞カラーを薄くして表示
                      tileColor: AppColors.getColor(word.category)
                          .withValues(alpha: 0.15),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // --- 戻るボタン群 ---
              _buildBackButton(
                context,
                label: '出題設定に戻る',
                times: 1, // リザルト → 出題設定
              ),
              const SizedBox(height: 8),
              _buildBackButton(
                context,
                label: '品詞選択に戻る',
                times: 2, // リザルト → 出題設定 → 品詞選択
              ),
              const SizedBox(height: 8),
              _buildBackButton(
                context,
                label: '言語選択に戻る',
                times: 3, // リザルト → 出題設定 → 品詞選択 → 言語選択
              ),
              const SizedBox(height: 8),
              _buildBackButton(
                context,
                label: 'はじめに戻る',
                times: 4, // リザルト → 出題設定 → 品詞選択 → 言語選択 → Home
              ),

            ],
          ),
        ),
      ),
    );
  }

  // 戻るボタンを作るメソッド
  Widget _buildBackButton(BuildContext context,
      {required String label, required int times}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _popTimes(context, times),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
