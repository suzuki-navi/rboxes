# dailynote

Create daily note files in markdown format with automatic linking for Obsidian vaults.

Obsidian vault用の自動リンク機能付きマークダウン形式デイリーノートファイルを作成します。

## Usage

```bash
dailynote <date> -d <directory>
dailynote <date> -d <directory> -f       # Force overwrite existing files / 既存ファイル強制上書き
```

### Options / オプション

- `-d, --directory <path>` - Output directory path / 出力ディレクトリパス
- `-f, --force` - Allow overwriting existing files / 既存ファイルの上書きを許可
- `--help` - Show help message / ヘルプメッセージを表示

### Arguments / 引数

- `date`: Date in YYYYMMDD format / YYYYMMDD形式の日付

### Examples / 使用例

```bash
# Create daily note in your Obsidian vault / Obsidianボルトにデイリーノートを作成
dailynote 20250815 -d ~/vault

# Force overwrite existing file / 既存ファイルを強制上書き
dailynote 20250815 -d ~/vault -f

```

## Features / 機能

- Creates daily note file with weekday and navigation links / 曜日とナビゲーションリンク付きデイリーノートファイルを作成
- Uses Obsidian WikiLink format (`[[YYYYMMDD]]`) for seamless vault integration / Obsidianボルトとのシームレス統合のためWikiLink形式（`[[YYYYMMDD]]`）を使用
- Creates monthly index file if it doesn't exist / 存在しない場合は月次インデックスファイルを作成
- Links to previous/next day and week / 前後の日と週へリンク
- Links to monthly overview / 月次概要へリンク
- Supports force overwrite with `-f` flag / `-f`フラグによる強制上書きをサポート
- Auto-directory creation with `-d @` / `-d @`による自動ディレクトリ作成
