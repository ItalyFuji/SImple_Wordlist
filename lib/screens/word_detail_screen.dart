import 'package:flutter/material.dart';
import '../models/word.dart';
import '../utils/app_colors.dart';
import '../utils/word_edit_manager.dart';

// 単語詳細画面
// 単語一覧からタップで開く。フラッシュカードと同じデザインのカードで全情報を表示。
// 編集ボタンから単語・意味・Tipsを修正できる。
class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {

  late Word _word;
  late String _originalId; // 編集してもIDが変わらないよう最初のIDを保持
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
    _originalId = widget.word.id;
  }

  void _onEdit() {
    final wordCtrl    = TextEditingController(text: _word.word);
    final meaningCtrl = TextEditingController(text: _word.meaning);
    final tipsCtrl    = TextEditingController(text: _word.tips);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('単語を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordCtrl,
              decoration: const InputDecoration(labelText: '単語'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: meaningCtrl,
              decoration: const InputDecoration(labelText: '意味'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tipsCtrl,
              decoration: const InputDecoration(labelText: 'Tips（任意）'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final newWord    = wordCtrl.text.trim();
              final newMeaning = meaningCtrl.text.trim();
              final newTips    = tipsCtrl.text.trim();

              await WordEditManager.saveEdit(
                _originalId,
                newWord:    newWord,
                newMeaning: newMeaning,
                newTips:    newTips,
              );

              // ダイアログを閉じる
              if (ctx.mounted) Navigator.pop(ctx);

              // 画面の状態を更新（screenのmountedで確認）
              if (!mounted) return;
              setState(() {
                _word = _word.copyWith(
                  word:    newWord,
                  meaning: newMeaning,
                  tips:    newTips,
                );
                _edited = true;
              });
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.getColor(_word.category);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // --- フラッシュカードと同じデザインのカード ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // 単語
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _word.word,
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 言語／品詞ラベル
                      Text(
                        '${_word.language}/${_word.category}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.black26, thickness: 1),
                      const SizedBox(height: 16),

                      // 意味
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _word.meaning,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Tips（あれば）
                      if (_word.tips.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _word.tips,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 戻る・編集ボタン ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _edited),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '戻る',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '編集',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
