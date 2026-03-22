import 'package:flutter/material.dart';
import '../models/quiz_session.dart';
import '../models/word.dart';
import '../utils/app_colors.dart';
import 'result_screen.dart';

// ⑤ 単語帳画面
class FlashcardScreen extends StatefulWidget {
  final QuizSession session;

  const FlashcardScreen({super.key, required this.session});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {

  bool _isRevealed = false;

  Word get _currentWord => widget.session.currentWord;

  // 表示側（隠さない側）のテキスト
  String get _visibleText => widget.session.hideTarget == 'word'
      ? _currentWord.meaning
      : _currentWord.word;

  // 隠す側のテキスト
  String get _hiddenText => widget.session.hideTarget == 'word'
      ? _currentWord.word
      : _currentWord.meaning;

  // YES/NOボタンが押されたときの処理
  void _onAnswer(bool remembered) {
    // answer()を呼ぶとindexが進んでhasNextが変わるため、
    // 「今が最後の問題か」を先に確認しておく
    final isLast = !widget.session.hasNext;

    widget.session.answer(remembered); // 正誤を記録してindexを進める

    if (isLast) {
      // 最後の問題だった → リザルト画面へ
      // pushReplacement: 現在の画面をリザルト画面に置き換える（戻れなくする）
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(session: widget.session),
        ),
      );
    } else {
      // まだ問題が残っている → 次の問題へ（revealedをリセット）
      setState(() => _isRevealed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = _currentWord;
    final cardColor = AppColors.getColor(word.category); // 品詞カラー

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        actions: [
          // 右上に進行度を表示（例: 1 / 5）
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${widget.session.currentIndex + 1} / ${widget.session.total}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // --- 外側カード（品詞カラー）---
                // padding分だけ白いカードより大きく見える = 「縁取り」効果
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12), // ★縁の太さ: 数字を大きくすると色付き縁が太くなる
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20), // ★外枠カードの角丸
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  // --- 内側カード（白）: 単語・意味・YES/NOボタンを含む ---
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // ★内側白カードの角丸
                    ),
                    padding: const EdgeInsets.all(24.0), // ★白カード内側の余白
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 子の高さに合わせる
                      children: [

                        // 表示側テキスト（単語 or 意味）
                        Text(
                          _visibleText,
                          style: const TextStyle(
                            fontSize: 60, // ★表示側（単語 or 意味）の文字サイズ
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8), // ★単語と品詞ラベルの間の余白

                        // 言語／品詞ラベル（単語の下・横線の上）
                        // word.language と word.category を組み合わせて表示
                        // 例: "English　／　名詞"
                        Text(
                          '${word.language}/${word.category}',
                          style: const TextStyle(
                            fontSize: 30, // ★品詞ラベルの文字サイズ
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 16), // ★品詞ラベルと横線の間の余白

                        // 区切り横線
                        const Divider(color: Colors.black26, thickness: 1),

                        const SizedBox(height: 16), // ★横線と隠し側の間の余白

                        // 隠し側: タップで公開
                        // SizedBox(height)で高さを固定することで、
                        // 公開前後でカードサイズが変わらないようにする
                        SizedBox(
                          height: 80, // ★隠し側エリアの固定高さ（公開前後で変わらない）
                          child: GestureDetector(
                            onTap: _isRevealed
                                ? null
                                : () => setState(() => _isRevealed = true),
                            child: Center(
                              child: _isRevealed
                                  ? Text(
                                      _hiddenText,
                                      style: const TextStyle(
                                        fontSize: 50, // ★隠し側（公開後）の文字サイズ
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : const Icon(
                                      Icons.block,
                                      size: 48, // ★🚫アイコンのサイズ
                                      color: Colors.black38,
                                    ),
                            ),
                          ),
                        ),

                        // 注釈（tipsが空でない場合のみ表示）
                        if (word.tips.isNotEmpty) ...[
                          const SizedBox(height: 16), // ★隠し側と注釈の間の余白
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8), // ★注釈枠の内側余白
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              word.tips,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24), // ★注釈とYES/NOの間の余白

                        // --- 覚えてた？ + YES/NOボタン ---
                        // AnimatedOpacity: 公開前は透明、公開後にフェードイン
                        AnimatedOpacity(
                          opacity: _isRevealed ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [

                              const Text(
                                '覚えてた？',
                                style: TextStyle(fontSize: 16), // ★「覚えてた？」の文字サイズ
                              ),

                              const SizedBox(height: 12), // ★「覚えてた？」とボタンの間の余白

                              // YES / NO ボタン（横並び）
                              Row(
                                children: [
                                  // YES ボタン（緑）
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isRevealed
                                          ? () => _onAnswer(true)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16), // ★YESボタンの縦の高さ
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'YES',
                                        style: TextStyle(
                                          fontSize: 18, // ★YESボタンの文字サイズ
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // NO ボタン（赤）
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isRevealed
                                          ? () => _onAnswer(false)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'NO',
                                        style: TextStyle(
                                          fontSize: 18, // ★NOボタンの文字サイズ
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
