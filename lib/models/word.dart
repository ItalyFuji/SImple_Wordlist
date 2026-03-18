class Word {
  final String language; // 言語（例: 英語）
  final String category; // 品詞（例: 名詞）
  final String word;     // 単語（例: Apple）
  final String meaning;  // 意味（例: りんご）
  final String tips;     // 注釈（例: 青森県と長野県が有名）

  const Word({
    required this.language,
    required this.category,
    required this.word,
    required this.meaning,
    required this.tips,
  });

  // CSVの1行（リスト）からWordを作るファクトリメソッド
  factory Word.fromCsvRow(List<dynamic> row) {
    return Word(
      language: row[0].toString().trim(),
      category: row[1].toString().trim(),
      word:     row[2].toString().trim(),
      meaning:  row[3].toString().trim(),
      tips:     row.length > 4 ? row[4].toString().trim() : '',
    );
  }
}
