import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/csv_loader.dart';
import 'category_select_screen.dart';

// ② 言語選択画面
// StatefulWidget: 画面の「状態」が変わるWidgetに使う
// この画面ではCSV読み込みの完了・未完了という状態が変わるためStatefulWidgetを使う
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {

  // 言語名のリスト（CSV読み込み後に入る）
  List<String> _languages = [];

  // 読み込み中かどうかのフラグ
  bool _isLoading = true;

  // initState: 画面が初めて表示されるときに1度だけ呼ばれる処理
  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  // CSVファイルから言語リストを読み込むメソッド
  Future<void> _loadLanguages() async {
    final languages = await CsvLoader.loadLanguageList();
    // setState: 状態が変わったことをFlutterに知らせて画面を再描画する
    setState(() {
      _languages = languages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ボタンの高さを固定するためにaspectRatioを動的に計算する
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
              // 読み込み中はくるくるを表示
              ? const Center(child: CircularProgressIndicator())
              // GridView.count: 列数を固定したグリッドレイアウト
              : GridView.count(
                  crossAxisCount: 2,         // 2列
                  crossAxisSpacing: spacing, // 列間の余白
                  mainAxisSpacing: spacing,  // 行間の余白
                  childAspectRatio: aspectRatio,
                  children: _languages
                      .map((language) => _buildLanguageButton(language))
                      .toList(),
                ),
        ),
      ),
    );
  }

  // 言語ボタンを作るメソッド
  Widget _buildLanguageButton(String language) {
    return ElevatedButton(
      onPressed: () {
        // Navigator.push: 新しい画面に移動する
        // 選んだ言語名（language）を次の画面に渡す
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelectScreen(language: language),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        // languageInfoから国旗と日本語名を取得して組み合わせる
        // 例: '🇬🇧 English（英語）'
        // ?? '' は、マップにキーがない場合に空文字を返す
        '${AppColors.languageInfo[language]?['flag'] ?? ''} $language（${AppColors.languageInfo[language]?['japanese'] ?? ''}）',
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}
