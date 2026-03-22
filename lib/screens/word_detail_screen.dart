import 'package:flutter/material.dart';
import '../models/word.dart';
import '../utils/app_colors.dart';
import '../utils/done_manager.dart';
import '../utils/user_word_manager.dart';
import '../utils/word_edit_manager.dart';

// 単語詳細画面
class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {

  late Word _word;
  late String _originalId;
  bool _edited  = false;
  bool _isDone  = false; // 覚えた状態

  @override
  void initState() {
    super.initState();
    _word       = widget.word;
    _originalId = widget.word.id;
    _loadDoneState();
  }

  Future<void> _loadDoneState() async {
    final doneMap = await DoneManager.getDoneMap([_word]);
    if (!mounted) return;
    setState(() => _isDone = doneMap[_word.id] ?? false);
  }

  // YES/NO 切り替え
  Future<void> _onToggleDone(bool done) async {
    await DoneManager.setDone(_word, done);
    if (!mounted) return;
    setState(() {
      _isDone = done;
      _edited = true; // 一覧をリロードさせる
    });
  }

  // 編集ダイアログ
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

              if (ctx.mounted) Navigator.pop(ctx);
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

  // 削除確認ダイアログ
  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除しますか？'),
        content: Text('「${_word.word}」を削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await UserWordManager.deleteWord(_word);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              Navigator.pop(context, true); // 一覧をリロードさせる
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
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

              // --- カード（削除ボタンをStackで右上に重ねる）---
              Stack(
                clipBehavior: Clip.none,
                children: [

                  // フラッシュカードと同じデザインのカード
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

                  // 削除ボタン（カード右上）
                  Positioned(
                    top: -12,
                    right: -12,
                    child: GestureDetector(
                      onTap: _onDelete,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 20),

              // --- YES / NO 切り替えボタン ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onToggleDone(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isDone ? Colors.green : Colors.green.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: _isDone
                              ? const BorderSide(color: Colors.green, width: 2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        'YES（覚えた）',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isDone ? Colors.white : Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onToggleDone(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !_isDone ? Colors.red : Colors.red.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: !_isDone
                              ? const BorderSide(color: Colors.red, width: 2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        'NO（未習得）',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: !_isDone ? Colors.white : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

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
