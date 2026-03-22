import 'package:sqflite/sqflite.dart';
import '../models/word.dart';
import 'database.dart';

// 単語の編集内容をSQLiteに保存・復元するクラス
class WordEditManager {

  // CSVから読んだWordに保存済みの編集を適用して返す
  static Future<Word> applyEdit(Word word) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'word_overrides',
      where: 'id = ?',
      whereArgs: [word.id],
    );
    if (rows.isEmpty) return word;
    final row = rows.first;
    return word.copyWith(
      word:    row['word']    as String,
      meaning: row['meaning'] as String,
      tips:    row['tips']    as String,
    );
  }

  // 複数のWordに一括で編集を適用する
  static Future<List<Word>> applyEdits(List<Word> words) async {
    if (words.isEmpty) return words;
    final db = await AppDatabase.database;

    // IN句で一度に全IDを検索
    final ids = words.map((w) => w.id).toList();
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT * FROM word_overrides WHERE id IN ($placeholders)',
      ids,
    );

    // id → rowのマップを作り、O(1)で検索
    final overrideMap = {for (final r in rows) r['id'] as String: r};

    return words.map((word) {
      final override = overrideMap[word.id];
      if (override == null) return word;
      return word.copyWith(
        word:    override['word']    as String,
        meaning: override['meaning'] as String,
        tips:    override['tips']    as String,
      );
    }).toList();
  }

  // 編集内容を保存する（同じIDが既にあれば上書き）
  static Future<void> saveEdit(
    String originalId, {
    required String newWord,
    required String newMeaning,
    required String newTips,
  }) async {
    final db = await AppDatabase.database;
    await db.insert(
      'word_overrides',
      {
        'id':      originalId,
        'word':    newWord,
        'meaning': newMeaning,
        'tips':    newTips,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
