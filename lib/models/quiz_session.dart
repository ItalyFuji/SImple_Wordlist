import 'word.dart';

class QuizSession {
  final List<Word> words;      // 出題する単語リスト
  final String hideTarget;     // 隠す側: 'word'（単語を隠す）or 'meaning'（意味を隠す）
  int currentIndex;            // 現在の問題番号（0始まり）
  final Map<int, bool> results; // 各問題の正誤: {0: true, 1: false, ...}

  QuizSession({
    required this.words,
    required this.hideTarget,
    this.currentIndex = 0,
    Map<int, bool>? results,
  }) : results = results ?? {};

  // 残り問題数
  int get total => words.length;

  // 現在の単語
  Word get currentWord => words[currentIndex];

  // まだ問題が残っているか
  bool get hasNext => currentIndex < words.length - 1;

  // 現在の問題に正誤を記録して次へ進む
  void answer(bool remembered) {
    results[currentIndex] = remembered;
    if (hasNext) currentIndex++;
  }

  // 正解数（「覚えてた」の数）
  int get correctCount => results.values.where((v) => v).length;
}
