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
      version: 2,
      onCreate: (db, version) async {

        // CSV単語の編集内容を保存するテーブル
        await db.execute('''
          CREATE TABLE word_overrides (
            id      TEXT PRIMARY KEY,
            word    TEXT NOT NULL,
            meaning TEXT NOT NULL,
            tips    TEXT NOT NULL
          )
        ''');

        // ユーザーが追加した単語を保存するテーブル
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

        // 削除された単語のIDを記録するテーブル
        // CSV単語は実際には消せないのでここに記録して非表示にする
        await db.execute('''
          CREATE TABLE IF NOT EXISTS hidden_words (
            id TEXT PRIMARY KEY
          )
        ''');

      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS hidden_words (
              id TEXT PRIMARY KEY
            )
          ''');
        }
      },
    );
  }
}
