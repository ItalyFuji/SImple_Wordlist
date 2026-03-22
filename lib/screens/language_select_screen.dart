import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/csv_loader.dart';
import 'category_select_screen.dart';

// ② 言語選択画面
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {

  List<String> _languages = [];
  bool _isLoading = true;

  // 選択中の言語を管理するSet（複数選択対応）
  final Set<String> _selected = {};

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

  // 言語ボタンをタップしたときの処理（選択 ↔ 解除のトグル）
  void _toggleLanguage(String language) {
    setState(() {
      if (_selected.contains(language)) {
        _selected.remove(language);
      } else {
        _selected.add(language);
      }
    });
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

                    // 言語選択グリッド
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _languages
                          .map((language) => _buildLanguageButton(language))
                          .toList(),
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategorySelectScreen(
                                          languages: _selected.toList(),
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

  // 言語ボタンを作るメソッド
  Widget _buildLanguageButton(String language) {
    final isSelected = _selected.contains(language);

    return ElevatedButton(
      onPressed: () => _toggleLanguage(language),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          // 選択中は赤枠
          side: isSelected
              ? const BorderSide(color: Colors.red, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Text(
        '${AppColors.languageInfo[language]?['flag'] ?? ''} $language',
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}
