import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/done_manager.dart';
import '../utils/word_edit_manager.dart';
import '../utils/user_word_manager.dart';
import '../models/word.dart';
import 'word_detail_screen.dart';
import 'word_add_screen.dart';

// 収録単語一覧画面
// 選択した言語の単語を全品詞・A→Z順で表示し、覚えた状態も確認できる
class WordListScreen extends StatefulWidget {
  final List<String> languages;

  const WordListScreen({super.key, required this.languages});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {

  List<Word> _words = [];
  Map<String, bool> _doneMap = {}; // word.id → 覚えた状態（true=〇 / false=✕）
  bool _isLoading = true;

  // 日本語の言語名から国旗絵文字を逆引きするメソッド
  // word.languageは'英語'などの日本語名なので、
  // languageInfoのjapaneseキーで検索して対応する国旗を返す
  String _getFlag(String japaneseName) {
    for (final entry in AppColors.languageInfo.entries) {
      if (entry.value['japanese'] == japaneseName) {
        return entry.value['flag'] ?? '';
      }
    }
    return ''; // 見つからなければ空文字
  }

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      // CSV単語＋ユーザー追加単語をまとめて取得
      final words = await UserWordManager.loadAll(widget.languages);

      // A→Z順にソート（大文字小文字を無視）
      words.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));

      // 全単語のdone状態を一括取得（編集前のIDで引く）
      final doneMap = await DoneManager.getDoneMap(words);

      // 保存済みの編集を適用
      final editedWords = await WordEditManager.applyEdits(words);

      setState(() {
        _words = editedWords;
        _doneMap = doneMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('_loadWords error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('収録単語一覧'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [

                  // 単語リスト（残りのスペースを全部使う）
                  Expanded(
                    child: ListView.separated(
                      itemCount: _words.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final word = _words[index];
                        final isDone = _doneMap[word.id] ?? false;

                        return InkWell(
                      onTap: () async {
                        final edited = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordDetailScreen(word: word),
                          ),
                        );
                        // 編集があった場合は一覧を再読み込み
                        if (edited == true) _loadWords();
                      },
                      child: Container(
                    // 背景色: 品詞カラーを薄く（リザルト画面と同じ）
                    color: AppColors.getColor(word.category)
                        .withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, // ★行の左右余白
                      vertical: 10,   // ★行の上下余白（大きくすると行が高くなる）
                    ),
                    child: Row(
                      children: [

                        // ── 言語列（国旗＋日本語名）────────────────
                        SizedBox(
                          width: 88, // ★言語列の幅
                          child: Text(
                            // 例: 🇫🇷 フランス語
                            // word.languageは日本語名（'フランス語'）なので
                            // _getFlagで国旗を逆引きしてから日本語名と組み合わせる
                            '${_getFlag(word.language)} ${word.language}',
                            style: const TextStyle(
                              fontSize: 10, // ★言語の文字サイズ
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 5), // ★言語列と単語列の間隔

                        // ── 単語／品詞列 ─────────────────────────
                        SizedBox(
                          width: 200, // ★単語+品詞列の幅
                          child: Text(
                            '${word.word}/${word.category}',
                            style: const TextStyle(
                              fontSize: 16, // ★単語の文字サイズ
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ── 意味列（残りのスペースを使う）────────────
                        Expanded(
                          child: Text(
                            word.meaning,
                            style: const TextStyle(fontSize: 15), // ★意味の文字サイズ
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ── 覚えた？列 ───────────────────────────
                        SizedBox(
                          width: 28, // ★〇✕列の幅
                          child: Text(
                            isDone ? '〇' : '✕',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, // ★〇✕の文字サイズ
                              fontWeight: FontWeight.bold,
                              color: isDone ? Colors.green : Colors.red,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),   // Container
                      );  // InkWell
                      },
                    ),
                  ),

                  // 「戻る」「単語追加」ボタン（横並び）
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 戻るボタン（左半分）
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
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
                        // 単語追加ボタン（右半分）
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final added = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WordAddScreen(
                                    csvLanguages: widget.languages,
                                  ),
                                ),
                              );
                              if (added == true) _loadWords();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              '単語追加',
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
      ),
    );
  }
}
