import 'package:flutter/material.dart';
import '../models/quiz_session.dart';

// ⑥ リザルト画面（仮）
// あとで実装する
class ResultScreen extends StatelessWidget {
  final QuizSession session;

  const ResultScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('リザルト')),
      body: Center(
        child: Text(
          'お疲れさまでした！\n'
          '正解: ${session.correctCount} / ${session.total}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
