import 'dart:convert'; // JSONの変換に使う（言語リスト取得で使用）
import 'package:flutter/services.dart'; // rootBundle（アプリ内ファイルの読み込み）に使う
import 'package:csv/csv.dart'; // CSVをDartのリストに変換するパッケージ
import '../models/word.dart';  // Wordクラスを使うためにインポート

class CsvLoader {

  // 指定した言語のCSVを読み込んで、Wordのリストを返す
  // 使い方: CsvLoader.load('English') → [Word, Word, ...]
  static Future<List<Word>> load(String language) async {
    // rootBundle.loadString: アプリにバンドルされたファイルをテキストとして読み込む
    final raw = await rootBundle.loadString('assets/data/$language.csv');

    // BOM文字(\uFEFF)と改行コードを正規化する
    // BOM: Windowsのメモ帳などで保存するとファイル先頭に付くことがある
    // \r\n → \n に統一してからパースする
    final normalized = raw
        .replaceAll('\uFEFF', '')   // BOM除去
        .replaceAll('\r\n', '\n')   // Windows改行 → Unix改行
        .replaceAll('\r', '\n');    // 古いMac改行 → Unix改行

    // csv 6.x では eol はコンストラクタで指定する（convert()に渡しても無視される）
    final rows = const CsvToListConverter(eol: '\n').convert(normalized);

    // rows[0] はヘッダー行（language,category,word,meaning,tips）なので
    // skip(1) で飛ばして、残りの各行をWordに変換してリストにする
    return rows.skip(1).map((row) => Word.fromCsvRow(row)).toList();
  }

  // assets/data/ にあるCSVファイルを自動検出して言語名リストを返す
  // 使い方: CsvLoader.loadLanguageList() → ['English', 'Deutsch', ...]
  // 新しい言語のCSVをassetsに追加するだけで自動的にリストに増える
  static Future<List<String>> loadLanguageList() async {
    // AssetManifest.json: アプリに含まれる全ファイルのパス一覧（Flutter自動生成）
    final manifestJson = await rootBundle.loadString('AssetManifest.json');

    // JSONをMapに変換する
    final manifest = json.decode(manifestJson) as Map<String, dynamic>;

    // 全パスの中から assets/data/ 以下の .csv ファイルだけを取り出す
    // 例: 'assets/data/English.csv' → 'English'
    return manifest.keys
        .where((path) => path.startsWith('assets/data/') && path.endsWith('.csv'))
        .map((path) => path.split('/').last.replaceAll('.csv', ''))
        .toList();
  }
}
