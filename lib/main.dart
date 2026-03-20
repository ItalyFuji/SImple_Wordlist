import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fontsパッケージ
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Wordlist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // textTheme: Textウィジェット全体のデフォルトフォントをNoto Sans JPに設定
        textTheme: GoogleFonts.notoSansJpTextTheme(),
        // elevatedButtonTheme: ElevatedButtonのテキストにも同じフォントを設定
        // ボタンのテキストはtextThemeとは別管理なので個別に指定が必要
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.notoSansJp(),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
