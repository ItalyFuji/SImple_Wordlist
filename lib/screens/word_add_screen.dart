import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/user_word_manager.dart';

// 単語追加画面
class WordAddScreen extends StatefulWidget {
  final List<String> csvLanguages; // CSVファイル名リスト（English, Deutschなど）

  const WordAddScreen({super.key, required this.csvLanguages});

  @override
  State<WordAddScreen> createState() => _WordAddScreenState();
}

class _WordAddScreenState extends State<WordAddScreen> {

  static const List<String> _categories = ['名詞', '動詞', '形容詞', '副詞', '間投詞'];

  late String _selectedLanguage; // 日本語名
  late String _selectedCategory;

  final _wordCtrl    = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _tipsCtrl    = TextEditingController();

  bool _isSaving = false;

  // CSVファイル名 → {日本語名, 国旗} のリスト
  List<Map<String, String>> get _languageOptions => widget.csvLanguages.map((lang) {
    final info = AppColors.languageInfo[lang];
    return {
      'csv':      lang,
      'japanese': info?['japanese'] ?? lang,
      'flag':     info?['flag']     ?? '',
    };
  }).toList();

  @override
  void initState() {
    super.initState();
    // 初期値: 最初の言語と品詞
    _selectedLanguage = _languageOptions.first['japanese']!;
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _tipsCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAdd() async {
    final word    = _wordCtrl.text.trim();
    final meaning = _meaningCtrl.text.trim();
    final tips    = _tipsCtrl.text.trim();

    if (word.isEmpty || meaning.isEmpty) return;

    setState(() => _isSaving = true);

    await UserWordManager.addWord(
      language: _selectedLanguage,
      category: _selectedCategory,
      word:     word,
      meaning:  meaning,
      tips:     tips,
    );

    if (!mounted) return;
    Navigator.pop(context, true); // trueで「追加した」を通知
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語を追加'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 言語選択
              const Text('言語', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _languageOptions.map((opt) => DropdownMenuItem(
                  value: opt['japanese'],
                  child: Text('${opt['flag']} ${opt['japanese']}'),
                )).toList(),
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),

              const SizedBox(height: 16),

              // 品詞選択
              const Text('品詞', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),

              const SizedBox(height: 16),

              // 単語入力
              const Text('単語', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _wordCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 16),

              // 意味入力
              const Text('意味', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _meaningCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 16),

              // Tips入力（任意）
              const Text('Tips（任意）', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _tipsCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 32),

              // ボタン
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('キャンセル',
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('追加',
                          style: TextStyle(fontSize: 18, color: Colors.black)),
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
