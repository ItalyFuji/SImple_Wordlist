// 単語1件分のデータを表すクラス
// CSVの1行が、このWordという「型」に変換される
class Word {
  final String language;   // 言語（例: 英語、ドイツ語）
  final String category;   // 品詞（例: 名詞、動詞）
  final String word;       // 単語（例: Apple）
  final String meaning;    // 意味（例: りんご）
  final String tips;       // 注釈（例: 青森県と長野県が有名）空のこともある
  final bool done;           // 習得済みか（true=Yes / false=No）
  final bool isUserAdded;    // trueならSQLiteのuser_wordsから読んだ単語
  final String? _originalId; // 編集後も変わらない元のID（SharedPreferences検索用）

  const Word({
    required this.language,
    required this.category,
    required this.word,
    required this.meaning,
    required this.tips,
    this.done = false,
    this.isUserAdded = false,
    String? originalId,
  }) : _originalId = originalId;

  factory Word.fromCsvRow(List<dynamic> row) {
    return Word(
      language: row[0].toString().trim(),
      category: row[1].toString().trim(),
      word:     row[2].toString().trim(),
      meaning:  row[3].toString().trim(),
      tips:     row.length > 4 ? row[4].toString().trim() : '',
      done:     row.length > 5 ? row[5].toString().trim() == 'Yes' : false,
    );
  }

  // SharedPreferencesのキーとして使う一意なID
  // 編集でwordテキストが変わっても、_originalIdがあれば元のIDを返す
  String get id => _originalId ?? '${language}_${category}_$word';

  // 一部のフィールドを変えた新しいWordを返す
  // originalIdを引き継ぐことでIDが変わらない
  Word copyWith({String? word, String? meaning, String? tips}) {
    return Word(
      language:    language,
      category:    category,
      word:        word    ?? this.word,
      meaning:     meaning ?? this.meaning,
      tips:        tips    ?? this.tips,
      done:        done,
      isUserAdded: isUserAdded,
      originalId:  id, // 元のIDを引き継ぐ
    );
  }
}
