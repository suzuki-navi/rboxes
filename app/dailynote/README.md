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
