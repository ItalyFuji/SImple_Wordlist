// 単語1件分のデータを表すクラス
// CSVの1行が、このWordという「型」に変換される
class Word {
  final String language; // 言語（例: 英語、ドイツ語）
  final String category; // 品詞（例: 名詞、動詞）
  final String word;     // 単語（例: Apple）
  final String meaning;  // 意味（例: りんご）
  final String tips;     // 注釈（例: 青森県と長野県が有名）空のこともある

  // コンストラクタ: Wordを作るときに必要な情報を受け取る
  // required = 省略不可
  const Word({
    required this.language,
    required this.category,
    required this.word,
    required this.meaning,
    required this.tips,
  });

  // ファクトリメソッド: CSVの1行（リスト形式）からWordを作る専用の方法
  // 例: ['英語', '名詞', 'Apple', 'りんご', '青森県と長野県が有名']
  //      row[0]   row[1]  row[2]   row[3]    row[4]
  factory Word.fromCsvRow(List<dynamic> row) {
    return Word(
      language: row[0].toString().trim(), // trim()で前後の空白を除去
      category: row[1].toString().trim(),
      word:     row[2].toString().trim(),
      meaning:  row[3].toString().trim(),
      // tipsはCSVにない場合もあるので、5列目があれば使い、なければ空文字にする
      tips:     row.length > 4 ? row[4].toString().trim() : '',
    );
  }
}
