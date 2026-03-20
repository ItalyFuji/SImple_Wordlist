import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

// 単語の習得状態（done）をSharedPreferencesで管理するクラス
// SharedPreferences: アプリを閉じても消えないシンプルなキーバリュー保存領域
class DoneManager {

  // SharedPreferencesのキーに付けるプレフィックス（他のデータと区別するため）
  // 例: 'done_英語_名詞_Apple' → true/false
  static const String _prefix = 'done_';

  // 単語の習得状態を取得する
  // 保存データがない場合はCSVのdoneの初期値を返す
  static Future<bool> isDone(Word word) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefix + word.id;
    // containsKey: そのキーが保存済みかどうかチェック
    // 未保存の場合はCSVの初期値（word.done）を使う
    if (prefs.containsKey(key)) {
      return prefs.getBool(key) ?? word.done;
    }
    return word.done; // SharedPreferencesに未登録ならCSVの値を使う
  }

  // 単語の習得状態を保存する
  // isDone: true=習得済み(Yes) / false=未習得(No)
  static Future<void> setDone(Word word, bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefix + word.id, isDone);
  }

  // 指定した単語リストのうち、習得済み(done=true)を除いたリストを返す
  // クイズ出題時に使う（覚えた単語は出さない）
  static Future<List<Word>> filterUndone(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    return words.where((word) {
      final key = _prefix + word.id;
      // SharedPreferencesに保存があればその値、なければCSVの初期値を使う
      final done = prefs.containsKey(key)
          ? (prefs.getBool(key) ?? word.done)
          : word.done;
      return !done; // done=falseの単語だけ残す
    }).toList();
  }

  // 全単語の習得状態をリセットする（全てNo/未習得に戻す）
  // 管理画面などから使う予定
  static Future<void> resetAll(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    for (final word in words) {
      await prefs.setBool(_prefix + word.id, false);
    }
  }
}
