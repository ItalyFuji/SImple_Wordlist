# Simple Wordlist

個人で作ったオフライン動作の語学単語帳アプリです。
CSVファイルに単語を追加するだけで、複数言語に対応できます。

---

## 画面構成

```
ホーム
├── はじめる → 言語選択 → 品詞選択 → 出題設定 → 単語帳（YES/NO） → リザルト
└── 収録単語一覧・単語追加 → 言語選択 → 単語一覧
```

---

## 主な機能

- 複数言語・複数品詞の同時出題
- YES / NO で覚えた単語を記録（SharedPreferences で端末に保存）
- 出題設定画面で「覚えた単語を除外する」トグル
- 収録単語一覧（A→Z順・覚えた状態つき）
- 単語帳はフラッシュカード形式（タップで答え表示）

---

## 対応言語

`assets/data/` に CSV ファイルを追加するだけで自動的に言語選択画面に表示されます。

| ファイル名 | 言語 |
|---|---|
| `English.csv` | 英語 |
| `Deutsch.csv` | ドイツ語 |
| `Français.csv` | フランス語 |
| `Italiano.csv` | イタリア語 |

---

## CSV フォーマット

1行目はヘッダー行（必須）。2行目以降が単語データ。

```
language,category,word,meaning,tips,done
英語,名詞,Apple,りんご,青森県と長野県が有名,No
英語,動詞,Run,走る,,No
```

| 列 | 内容 | 例 |
|---|---|---|
| language | 言語名（日本語） | 英語 |
| category | 品詞（名詞 / 動詞 / 形容詞 / 副詞） | 名詞 |
| word | 単語 | Apple |
| meaning | 意味 | りんご |
| tips | 補足（空欄可） | 青森県と長野県が有名 |
| done | 初期習得状態（Yes / No） | No |

---

## 開発・実行コマンド

### パッケージのインストール
```bash
flutter pub get
```

### Chrome でシミュレート
```bash
flutter run -d chrome
```

### 接続中の Android 実機で実行
```bash
flutter devices          # 接続デバイスを確認
flutter run              # デバイスが1台なら自動選択
```

### Android APK をビルド（デモ配布用）
```bash
flutter build apk --debug
```
生成先: `build/app/outputs/flutter-apk/app-debug.apk`
Google Drive や LINE でスマホに送ってインストールできます。

> **注意:** アセット（CSV など）を変更した場合はホットリロード（`r`）ではなく
> フルリスタート（`R`）または `flutter run` のやり直しが必要です。

---

## 使用パッケージ

| パッケージ | 用途 |
|---|---|
| `csv ^6.0.0` | CSV ファイルのパース |
| `google_fonts ^6.2.1` | Noto Sans JP フォント |
| `shared_preferences ^2.3.3` | YES/NO 結果の端末保存 |

---

## 今後の予定

- **単語追加機能**（未実装）
  `sqflite` を使った SQLite による実装を予定。
  元 CSV はデフォルト単語帳、ユーザー追加単語は SQLite で管理する方針。

---

## ディレクトリ構成

```
lib/
├── main.dart
├── models/
│   ├── word.dart          # 単語データモデル
│   └── quiz_session.dart  # 出題セッション管理
├── screens/
│   ├── home_screen.dart
│   ├── language_select_screen.dart
│   ├── category_select_screen.dart
│   ├── settings_screen.dart
│   ├── flashcard_screen.dart
│   ├── result_screen.dart
│   └── word_list_screen.dart
└── utils/
    ├── app_colors.dart    # 色・フォント定数
    ├── csv_loader.dart    # CSV 読み込み
    └── done_manager.dart  # YES/NO 状態管理

assets/
└── data/
    ├── English.csv
    ├── Deutsch.csv
    ├── Français.csv
    └── Italiano.csv
```
