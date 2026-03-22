import 'package:sqflite/sqflite.dart';
import '../models/word.dart';
import '../utils/app_colors.dart';
import '../utils/csv_loader.dart';
import 'database.dart';

// ユーザーが追加した単語をSQLiteで管理するクラス
class UserWordManager {

  // 削除済み単語のIDセットを取得
  static Future<Set<String>> _getHiddenIds(Database db) async {
    final rows = await db.query('hidden_words');
    return rows.map((r) => r['id'] as String).toSet();
  }

  // CSVのファイル名リスト（English, Deutschなど）に対応するユーザー単語を取得
  static Future<List<Word>> loadWords(
      List<String> csvLanguages, Set<String> hiddenIds) async {
    if (csvLanguages.isEmpty) return [];
    final db = await AppDatabase.database;

    // CSVファイル名 → 日本語名に変換（user_wordsはCSV同様に日本語名で保存）
    final japaneseNames = csvLanguages
        .map((lang) => AppColors.languageInfo[lang]?['japanese'] ?? lang)
        .toList();

    final placeholders = List.filled(japaneseNames.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT * FROM user_words WHERE language IN ($placeholders)',
      japaneseNames,
    );

    // ユーザー追加単語はDBから直接削除されるためhiddenIdsでフィルタ不要
    return rows
        .map((r) => Word(
              language:    r['language'] as String,
              category:    r['category'] as String,
              word:        r['word']     as String,
              meaning:     r['meaning']  as String,
              tips:        r['tips']     as String,
              done:        (r['done'] as int) == 1,
              isUserAdded: true,
            ))
        .toList();
  }

  // CSV単語＋ユーザー追加単語をまとめて返す（削除済みを除外）
  static Future<List<Word>> loadAll(List<String> csvLanguages) async {
    final db        = await AppDatabase.database;
    final hiddenIds = await _getHiddenIds(db);

    final csvWords  = (await CsvLoader.loadMultiple(csvLanguages))
        .where((w) => !hiddenIds.contains(w.id))
        .toList();
    final userWords = await loadWords(csvLanguages, hiddenIds);
    return [...csvWords, ...userWords];
  }

  // 単語を追加する
  static Future<void> addWord({
    required String language, // 日本語名（英語、ドイツ語など）
    required String category,
    required String word,
    required String meaning,
    required String tips,
  }) async {
    final db = await AppDatabase.database;
    await db.insert('user_words', {
      'language': language,
      'category': category,
      'word':     word,
      'meaning':  meaning,
      'tips':     tips,
      'done':     0,
    });
  }

  // 単語を削除する
  // ユーザー追加単語 → user_wordsから削除
  // CSV単語 → hidden_wordsに追加して非表示化
  static Future<void> deleteWord(Word word) async {
    final db = await AppDatabase.database;

    if (word.isUserAdded) {
      // user_wordsから削除（元の単語テキストで一致させる）
      await db.delete(
        'user_words',
        where: 'language = ? AND category = ? AND word = ?',
        whereArgs: [word.language, word.category, word.word],
      );
    } else {
      // hidden_wordsに追加
      await db.insert(
        'hidden_words',
        {'id': word.id},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
