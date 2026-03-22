import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// アプリ全体で使うSQLiteデータベースの管理クラス
class AppDatabase {
  static Database? _db;

  // データベースのインスタンスを返す（初回のみ開く）
  static Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'simple_wordlist.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        // CSV単語の編集内容を保存するテーブル
        // id: CSV単語の元ID（language_category_word）
        await db.execute('''
          CREATE TABLE word_overrides (
            id      TEXT PRIMARY KEY,
            word    TEXT NOT NULL,
            meaning TEXT NOT NULL,
            tips    TEXT NOT NULL
          )
        ''');

        // ユーザーが追加した単語を保存するテーブル（単語追加機能用）
        await db.execute('''
          CREATE TABLE user_words (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            language TEXT NOT NULL,
            category TEXT NOT NULL,
            word     TEXT NOT NULL,
            meaning  TEXT NOT NULL,
            tips     TEXT NOT NULL,
            done     INTEGER NOT NULL DEFAULT 0
          )
        ''');

      },
    );
  }
}
