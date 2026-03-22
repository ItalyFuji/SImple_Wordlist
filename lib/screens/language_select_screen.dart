import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/csv_loader.dart';
import 'category_select_screen.dart';

// ② 言語選択画面
// onConfirm が指定された場合（単語一覧用）: 次へ押下で onConfirm(選択言語リスト) を呼ぶ
// onConfirm が null の場合（クイズ用）: 次へ押下で CategorySelectScreen に遷移する
class LanguageSelectScreen extends StatefulWidget {
  final void Function(List<String> languages)? onConfirm;

  const LanguageSelectScreen({super.key, this.onConfirm});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {

  List<String> _languages = [];
  bool _isLoading = true;

  // 選択中の言語を管理するSet（複数選択対応）
  final Set<String> _selected = {};

  // 全ての言語が選択されているか判定するゲッター
  bool get _isAllSelected =>
      _languages.isNotEmpty && _languages.every((l) => _selected.contains(l));

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final languages = await CsvLoader.loadLanguageList();
    setState(() {
      _languages = languages;
      _isLoading = false;
    });
  }

  // 言語ボタンをタップしたときの処理
  void _toggleLanguage(String language) {
    setState(() {
      if (language == '全部') {
        // 「全部」タップ: 全選択 ↔ 全解除 のトグル
        if (_isAllSelected) {
          _selected.clear(); // 全解除
        } else {
          _selected.addAll(_languages); // 全選択
        }
      } else {
        // 個別言語タップ: 選択 ↔ 解除 のトグル
        if (_selected.contains(language)) {
          _selected.remove(language);
        } else {
          _selected.add(language);
        }
      }
    });
  }

  // そのボタンが「選択中」かどうかを返す
  bool _isSelected(String language) {
    if (language == '全部') return _isAllSelected;
    return _selected.contains(language);
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 60;
    const double spacing = 12;
    const double padding = 24;
    final buttonWidth =
        (MediaQuery.of(context).size.width - padding * 2 - spacing) / 2;
    final aspectRatio = buttonWidth / buttonHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('言語を選択'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [

                    // 言語選択グリッド（2列）
                    // 「全部」ボタンは常に最後に来るよう末尾に追加
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ..._languages.map((language) => _buildLanguageButton(language)),
                        _buildLanguageButton('全部'),
                        // 言語数+1が奇数の場合、空マスを追加して「全部」を最後に固定
                        if ((_languages.length + 1) % 2 != 0) const SizedBox(),
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
                        // 次へボタン（右半分・未選択なら無効）
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selected.isEmpty
                                ? null
                                : () {
                                    final langs = _selected.toList();
                                    if (widget.onConfirm != null) {
                                      // 単語一覧モード: コールバックを呼ぶ
                                      widget.onConfirm!(langs);
                                    } else {
                                      // クイズモード: 品詞選択画面へ
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CategorySelectScreen(
                                            languages: langs,
                                          ),
                                        ),
                                      );
                                    }
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

  // 言語ボタンを作るメソッド
  Widget _buildLanguageButton(String language) {
    final isSelected = _isSelected(language);
    // 「全部」はグレー、それ以外は藤色
    final color = language == '全部'
        ? AppColors.defaultCategoryColor
        : AppColors.primary;
    // 「全部」はそのまま、それ以外はフラグ絵文字と言語名を表示
    final label = language == '全部'
        ? '全部'
        : '${AppColors.languageInfo[language]?['flag'] ?? ''} $language';

    return ElevatedButton(
      onPressed: () => _toggleLanguage(language),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          // 選択中は赤枠
          side: isSelected
              ? const BorderSide(color: Colors.red, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}
