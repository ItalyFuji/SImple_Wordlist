import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// アプリ全体で使う色の定数をまとめたクラス
// ここを変えるだけでアプリ全体の色が変わる
class AppColors {

  // フォントスタイルを作るメソッド
  // 使い方: AppColors.textStyle(fontSize: 16, color: Colors.black)
  // main.dartでデフォルト設定済みなので、特別な指定が必要なときだけ使う
  static TextStyle textStyle({
    double fontSize = 16,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.notoSansJp(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // アプリのメインカラー（藤色）
  static const Color primary = Color(0xFFBAA7CC);

  // 言語ファイル名 → {国旗絵文字, 日本語名} のマップ
  // キー: CSVファイル名（拡張子なし）
  static const Map<String, Map<String, String>> languageInfo = {
    'English':  {'flag': '🇬🇧', 'japanese': '英語'},
    'Deutsch':  {'flag': '🇩🇪', 'japanese': 'ドイツ語'},
    'Français': {'flag': '🇫🇷', 'japanese': 'フランス語'},
    'Italiano': {'flag': '🇮🇹', 'japanese': 'イタリア語'},
  };

  // 品詞ごとのカード背景色
  // 0xFF＋6桁の16進数カラーコード（0xFF = 不透明100%）
  static const Map<String, Color> categoryColors = {
    '名詞':  Color(0xFF7058a3), // 菫色
    '動詞':  Color(0xFF3eb370), // 緑
    '形容詞': Color(0xFFFFD900), // 黄色
    '副詞':  Color(0xFFf8b500), // 山吹色
    '間投詞': Color(0xFF2ca9e1), // 水色
  };

  // 上記以外の品詞が来たときに使うデフォルトの色
  static const Color defaultCategoryColor = Color(0xFFc0c6c9); // 灰青

  // 品詞名を渡すと対応する色を返すメソッド
  // ?? は「nullなら右側を使う」という意味
  // 例: AppColors.getColor('名詞') → 紫
  //     AppColors.getColor('接続詞') → グレー（Mapにないのでデフォルト）
  static Color getColor(String category) {
    return categoryColors[category] ?? defaultCategoryColor;
  }
}
