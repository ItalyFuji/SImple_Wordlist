// 単語1件分のデータを表すクラス
// CSVの1行が、このWordという「型」に変換される
class Word {
  final String language; // 言語（例: 英語、ドイツ語）
  final String category; // 品詞（例: 名詞、動詞）
  final String word;     // 単語（例: Apple）
  final String meaning;  // 意味（例: りんご）
  final String tips;     // 注釈（例: 青森県と長野県が有名）空のこともある
  // doneはCSVから読むが、実際の状態はSharedPreferencesで管理する
  // このフィールドはCSVの初期値として使うだけ
  final bool done;       // 習得済みか（true=Yes=出題しない / false=No=出題する）

  // コンストラクタ: Wordを作るときに必要な情報を受け取る
  // required = 省略不可
  const Word({
    required this.language,
    required this.category,
    required this.word,
    required this.meaning,
    required this.tips,
    this.done = false, // デフォルトはfalse（未習得）
  });

  // ファクトリメソッド: CSVの1行（リスト形式）からWordを作る専用の方法
  // 例: ['英語', '名詞', 'Apple', 'りんご', '青森県と長野県が有名', 'No']
  //      row[0]   row[1]  row[2]   row[3]    row[4]                  row[5]
  factory Word.fromCsvRow(List<dynamic> row) {
    return Word(
      language: row[0].toString().trim(),
      category: row[1].toString().trim(),
      word:     row[2].toString().trim(),
      meaning:  row[3].toString().trim(),
      tips:     row.length > 4 ? row[4].toString().trim() : '',
      // CSVのdone列: 'Yes'ならtrue、それ以外（'No'や空）はfalse
      done:     row.length > 5 ? row[5].toString().trim() == 'Yes' : false,
    );
  }

  // SharedPreferencesのキーとして使う一意なID
  // 例: '英語_名詞_Apple'
  // 同じ単語でも言語・品詞が違えば別キーになる
  String get id => '${language}_${category}_$word';
}
