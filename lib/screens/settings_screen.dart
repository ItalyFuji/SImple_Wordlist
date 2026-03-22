import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/csv_loader.dart';
import '../models/word.dart';
import '../models/quiz_session.dart';
import 'flashcard_screen.dart'; // 次の画面（あとで作る）

// ④ 出題設定画面
class SettingsScreen extends StatefulWidget {
  final List<String> languages;  // 前の画面から受け取る言語リスト（複数対応）
  final List<String> categories; // 前の画面から受け取る品詞リスト

  const SettingsScreen({
    super.key,
    required this.languages,
    required this.categories,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // 問題数の選択肢（0は「全部」を意味する特別な値として使う）
  static const List<int> _countOptions = [5, 10, 20, 50, 100, 0];

  // 読み込んだ利用可能な単語リスト
  List<Word> _availableWords = [];
  bool _isLoading = true;

  // 選択中の問題数（nullは未選択）
  int? _selectedCount;

  // 隠す側: 'word'=単語を隠す / 'meaning'=意味を隠す
  String _hideTarget = 'meaning'; // デフォルトは意味を隠す

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  // CSVから単語を読み込み、選択した品詞でフィルタリングする
  Future<void> _loadWords() async {
    // 複数言語のCSVをまとめて読み込む
    final allWords = await CsvLoader.loadMultiple(widget.languages);

    // 選択した品詞に含まれる単語だけ残す
    final filtered = allWords
        .where((w) => widget.categories.contains(w.category))
        .toList();

    setState(() {
      _availableWords = filtered;
      _isLoading = false;
    });
  }

  // 問題数ボタンのラベルを返す（0は「全部」と表示）
  String _countLabel(int count) => count == 0 ? '全部' : '$count';

  // その問題数が選択可能か判定する
  // 利用可能な単語数より多い問題数は選べない（ただし「全部」は常に選択可能）
  bool _isCountEnabled(int count) {
    if (count == 0) return true; // 「全部」は常に有効
    return count <= _availableWords.length;
  }

  // 実際の出題数を返す（「全部」なら単語数をそのまま返す）
  int get _actualCount =>
      _selectedCount == 0 ? _availableWords.length : (_selectedCount ?? 0);

  @override
  Widget build(BuildContext context) {
    // 問題数ボタンの高さ固定計算（2列）
    const double buttonHeight = 56;
    const double spacing = 10;
    const double padding = 24;
    final buttonWidth =
        (MediaQuery.of(context).size.width - padding * 2 - spacing) / 2;
    final aspectRatio = buttonWidth / buttonHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.languages.join('・')),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 選択中の言語・品詞を表示
                    // 例: English・Deutsch ／ 名詞・動詞
                    Center(
                      child: Text(
                        '${widget.languages.join('・')}\n${widget.categories.join('・')}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 利用可能な単語数を表示
                    Center(
                      child: Text(
                        '利用可能な単語数: ${_availableWords.length}語',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- 問題数セクション ---
                    const Text(
                      '問題数',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 問題数ボタングリッド（2列×3行）
                    // 並び順: [5,10] [20,50] [100,全部]
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _countOptions
                          .map((count) => _buildCountButton(count))
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // --- どちらを隠す？セクション ---
                    const Text(
                      'どちらを隠す？',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 単語 / 意味 の2択ボタン（横並び）
                    Row(
                      children: [
                        Expanded(child: _buildHideButton('word', '単語')),
                        const SizedBox(width: spacing),
                        Expanded(child: _buildHideButton('meaning', '意味')),
                      ],
                    ),

                    const Spacer(),

                    // 「戻る」「次へ」ボタン（横並び）
                    Row(
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
                        // 次へボタン（右半分・問題数未選択なら無効）
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedCount == null
                                ? null
                                : () {
                                    // QuizSessionを作って単語帳画面へ渡す
                                    // 単語リストをシャッフルして先頭から_actualCount件取り出す
                                    final shuffled = List<Word>.from(_availableWords)
                                      ..shuffle();
                                    final quizWords =
                                        shuffled.take(_actualCount).toList();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FlashcardScreen(
                                          session: QuizSession(
                                            words: quizWords,
                                            hideTarget: _hideTarget,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              '次へ',
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

  // 問題数ボタンを作るメソッド
  Widget _buildCountButton(int count) {
    final isSelected = _selectedCount == count;
    final isEnabled = _isCountEnabled(count);

    return ElevatedButton(
      // 無効な場合はonPressedをnullにしてグレーアウト
      onPressed: isEnabled ? () => setState(() => _selectedCount = count) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: Colors.grey.shade200, // 無効時の色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          // 選択中は赤枠
          side: isSelected
              ? const BorderSide(color: Colors.red, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Text(
        _countLabel(count),
        style: TextStyle(
          fontSize: 16,
          color: isEnabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  // 隠す側ボタンを作るメソッド（単語 / 意味）
  Widget _buildHideButton(String value, String label) {
    final isSelected = _hideTarget == value;

    return ElevatedButton(
      onPressed: () => setState(() => _hideTarget = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected
              ? const BorderSide(color: Colors.red, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
