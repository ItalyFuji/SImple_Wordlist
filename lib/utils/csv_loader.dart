import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/word.dart';

class CsvLoader {
  // 指定した言語のCSVファイルを読み込んでWordのリストを返す
  static Future<List<Word>> load(String language) async {
    final raw = await rootBundle.loadString('assets/data/$language.csv');
    final rows = const CsvToListConverter().convert(raw, eol: '\n');

    // 1行目はヘッダー（language,category,word,meaning,tips）なのでスキップ
    return rows.skip(1).map((row) => Word.fromCsvRow(row)).toList();
  }

  // assets/data/ にあるCSVから言語名リストを返す
  static Future<List<String>> loadLanguageList() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final manifest = json.decode(manifestJson) as Map<String, dynamic>;

    return manifest.keys
        .where((path) => path.startsWith('assets/data/') && path.endsWith('.csv'))
        .map((path) => path.split('/').last.replaceAll('.csv', ''))
        .toList();
  }
}
