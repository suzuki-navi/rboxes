# backlogexp

Backlogプロジェクトデータエクスポートツール

## 概要

プロジェクト管理ツールBacklogからプロジェクトデータを一括エクスポートするコマンドラインツールです。Backlog APIを使用して、課題（Issue）やプロジェクト情報を構造化されたファイル形式で取得し、カレントディレクトリに保存します。

## 使用方法

```bash
backlogexp [オプション] <プロジェクトキー>
```

### オプション

- `--help` - このヘルプメッセージを表示して終了

### 引数

- `プロジェクトキー` - Backlogプロジェクトキー（例: "MYPROJ"）

## 環境変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `BACKLOG_SPACE` | Backlogスペース名（サブドメインのみ、完全なURLではない） | `mycompany` (mycompany.backlog.jp の場合) |
| `BACKLOG_SUFFIX` | ドメインサフィックス: "jp" または "com"（デフォルト: "jp"） | `jp` |
| `BACKLOG_API_KEY` | Backlog APIキー | `your-api-key-here` |

## 主な機能

### 1. プロジェクト情報のエクスポート
- プロジェクトの基本情報（ID、キー、名前）をYAML形式で保存
- ファイル名: `project_{プロジェクトキー}.yml`

### 2. 課題の個別エクスポート
- 各課題を独立したYAMLファイルとして保存
- 課題の詳細情報（概要、説明、ステータス、優先度、担当者など）を含む
- 全てのコメントも各課題ファイルに統合
- ファイル名: `{課題キー}_{概要}.yml`

### 3. 課題一覧表の作成
- 全課題の概要をMarkdownテーブル形式で出力
- 課題キー、ステータス、作成日、概要の4列で構成
- 東アジア文字（日本語等）の文字幅を考慮した美しい表レイアウト
- ファイル名: `issue_list.md`

### 4. 自動ドキュメント生成
- エクスポート内容を説明するREADME.mdを自動作成
- エクスポート日時、件数、ファイル構造などの情報を含む

## 使用例

```bash
# https://mycompany.backlog.jp の場合:
export BACKLOG_SPACE="mycompany"
export BACKLOG_SUFFIX="jp"
export BACKLOG_API_KEY="your-api-key-here"

# https://example.backlog.com の場合:
export BACKLOG_SPACE="example"
export BACKLOG_SUFFIX="com"
export BACKLOG_API_KEY="your-api-key-here"

# エクスポート実行
backlogexp PROJ
```

## 出力ファイル構造

```
.
├── README.md                       # エクスポート内容の説明
├── project_MYPROJ.yml              # プロジェクト情報
├── issue_list.md                   # 課題一覧表（Markdown）
└── issues/                         # 個別課題ファイル
    ├── MYPROJ-1_初期セットアップ.yml
    ├── MYPROJ-2_ログイン機能.yml
    └── ...
```

## 特徴

- 課題の全ての情報（メタデータ、説明、コメント）を保持
- ページングを使用して全データを確実に取得
- 人間が読みやすいYAML形式
- ファイル名の自動サニタイズ（無効文字の置換）

## APIキーの取得方法

1. Backlogスペースにログイン
2. 個人設定 > API に移動
3. 新しいAPIキーを生成
4. 必要な環境変数を設定
