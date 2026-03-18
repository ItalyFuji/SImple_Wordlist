import 'package:flutter/material.dart';

class AppColors {
  // 品詞ごとのカード背景色
  static const Map<String, Color> categoryColors = {
    '名詞': Color(0xFFCE93D8),   // 紫
    '動詞': Color(0xFFA5D6A7),   // 緑
    '形容詞': Color(0xFFFFF176), // 黄色
    '副詞': Color(0xFFFFCC80),   // オレンジ
  };

  // 上記以外の品詞が来たときのデフォルト色
  static const Color defaultCategoryColor = Color(0xFFB0BEC5); // グレー

  // 品詞名から色を取得するメソッド
  static Color getColor(String category) {
    return categoryColors[category] ?? defaultCategoryColor;
  }
}
