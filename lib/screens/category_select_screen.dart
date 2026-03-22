import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'settings_screen.dart'; // 次の画面（あとで作る）

// ③ 品詞選択画面
class CategorySelectScreen extends StatefulWidget {
  final List<String> languages; // 前の画面から受け取る言語リスト（複数対応）

  const CategorySelectScreen({super.key, required this.languages});

  @override
  State<CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends State<CategorySelectScreen> {

  // 表示するボタンの固定リスト（順番もここで管理）
  static const List<String> _buttons = ['名詞', '動詞', '形容詞', '副詞', '間投詞', '全部'];

  // 実際の品詞リスト（「全部」は含まない）
  static const List<String> _realCategories = ['名詞', '動詞', '形容詞', '副詞', '間投詞'];

  // 選択中の品詞を管理するSet（重複なしのリスト）
  // 例: {'名詞', '動詞'}
  final Set<String> _selected = {};

  // 全ての品詞が選択されているか判定するゲッター
  bool get _isAllSelected =>
      _realCategories.every((c) => _selected.contains(c));

  // ボタンをタップしたときの処理
  void _toggleCategory(String category) {
    setState(() {
      if (category == '全部') {
        // 「全部」タップ: 全選択 ↔ 全解除 のトグル
        if (_isAllSelected) {
          _selected.clear(); // 全解除
        } else {
          _selected.addAll(_realCategories); // 全選択
        }
      } else {
        // 個別品詞タップ: 選択 ↔ 解除 のトグル
        if (_selected.contains(category)) {
          _selected.remove(category);
        } else {
          _selected.add(category);
        }
      }
    });
  }

  // そのボタンが「選択中」かどうかを返す
  bool _isSelected(String category) {
    if (category == '全部') return _isAllSelected;
    return _selected.contains(category);
  }

  // ボタンの背景色を返す（常に同じ色。選択状態で変えない）
  Color _buttonColor(String category) {
    return category == '全部'
        ? AppColors.defaultCategoryColor
        : AppColors.getColor(category);
  }

  @override
  Widget build(BuildContext context) {
    // ボタンの高さ固定（言語選択画面と同じ計算方法）
    const double buttonHeight = 80;  // 高さを大きめに
    const double spacing = 12;
    const double padding = 24;
    // 2列なので列間スペースは1つ分
    final buttonWidth =
        (MediaQuery.of(context).size.width - padding * 2 - spacing) / 2;
    final aspectRatio = buttonWidth / buttonHeight;

    return Scaffold(
      appBar: AppBar(
        // 選択した言語を「・」でつないで表示（例: English・Deutsch）
        title: const Text('品詞を選択'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [

              // 品詞選択グリッド（2列×3行）
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
                shrinkWrap: true, // Columnの中に入れるために必要
                physics: const NeverScrollableScrollPhysics(), // スクロール無効
                children: [
                  ..._buttons.map((category) => _buildCategoryButton(category)),
                  // 6ボタンで2列 → ちょうど3行でぴったり埋まる
                ],
              ),

              const Spacer(), // 残りのスペースを埋めてボタンを下に押し込む

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
                          ? null // null にするとボタンが無効化される
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsScreen(
                                    languages: widget.languages,
                                    categories: _selected.toList(),
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

  // 品詞ボタンを作るメソッド
  Widget _buildCategoryButton(String category) {
    return ElevatedButton(
      onPressed: () => _toggleCategory(category),
      style: ElevatedButton.styleFrom(
        // 選択状態に応じて色を変える
        backgroundColor: _buttonColor(category),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          // 選択中は赤い枠線、未選択は枠線なし
          side: _isSelected(category)
              ? const BorderSide(color: Colors.red, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Text(
        category,
        style: const TextStyle(fontSize: 40, color: Colors.black),
      ),
    );
  }
}
