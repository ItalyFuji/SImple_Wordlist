import 'word.dart';

// クイズ1回分の「状態」をまとめて管理するクラス
// 出題する単語・今何問目か・正誤の記録などを持ち運ぶ「バトン」の役割
class QuizSession {
  final List<Word> words;       // 出題する単語のリスト
  final String hideTarget;      // 何を隠すか: 'word'（単語を隠す）or 'meaning'（意味を隠す）
  int currentIndex;             // 今何問目か（0始まり: 0=1問目, 1=2問目...）
  final Map<int, bool> results; // 各問題の正誤記録: {0: true, 1: false, ...}
                                // キーが問題番号、値がtrue=覚えてた/false=覚えてなかった

  // コンストラクタ
  // results は省略可能（省略した場合は空のMapで始まる）
  QuizSession({
    required this.words,
    required this.hideTarget,
    this.currentIndex = 0,      // 最初は0問目からスタート
    Map<int, bool>? results,
  }) : results = results ?? {}; // nullなら空のMapを使う

  // --- ゲッター（計算して返すプロパティ） ---

  // 総問題数
  int get total => words.length;

  // 今表示すべき単語
  Word get currentWord => words[currentIndex];

  // まだ次の問題があるか
  bool get hasNext => currentIndex < words.length - 1;

  // --- メソッド（処理） ---

  // 「覚えてた」か「覚えてなかった」を記録して、次の問題へ進む
  // remembered: true=覚えてた / false=覚えてなかった
  void answer(bool remembered) {
    results[currentIndex] = remembered; // 現在の問題番号に正誤を記録
    if (hasNext) currentIndex++;        // 次の問題があれば進む
  }

  // 「覚えてた」の数を数える
  int get correctCount => results.values.where((v) => v).length;
}
