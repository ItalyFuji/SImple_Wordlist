import 'package:flutter/material.dart';

// アプリ全体で使う色の定数をまとめたクラス
// ここを変えるだけでアプリ全体の色が変わる
class AppColors {

  // 品詞ごとのカード背景色
  // 0xFF＋6桁の16進数カラーコード（0xFF = 不透明100%）
  static const Map<String, Color> categoryColors = {
    '名詞':  Color(0xFFCE93D8), // 紫
    '動詞':  Color(0xFFA5D6A7), // 緑
    '形容詞': Color(0xFFFFF176), // 黄色
    '副詞':  Color(0xFFFFCC80), // オレンジ
  };

  // 上記以外の品詞が来たときに使うデフォルトの色
  static const Color defaultCategoryColor = Color(0xFFB0BEC5); // グレー

  // 品詞名を渡すと対応する色を返すメソッド
  // ?? は「nullなら右側を使う」という意味
  // 例: AppColors.getColor('名詞') → 紫
  //     AppColors.getColor('接続詞') → グレー（Mapにないのでデフォルト）
  static Color getColor(String category) {
    return categoryColors[category] ?? defaultCategoryColor;
  }
}
