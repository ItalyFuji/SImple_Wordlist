import 'package:flutter/material.dart';
import '../models/quiz_session.dart';

// ⑤ 単語帳画面（仮）
// あとで実装する
class FlashcardScreen extends StatelessWidget {
  final QuizSession session;

  const FlashcardScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('単語帳')),
      body: Center(
        child: Text(
          '単語帳画面（工事中）\n'
          '問題数: ${session.total}\n'
          '隠す側: ${session.hideTarget}',
        ),
      ),
    );
  }
}
