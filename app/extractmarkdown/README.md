# extractmarkdown

Extract files from markdown code blocks

Markdownコードブロックからファイルを抽出

## Overview

A command-line tool that extracts files from Markdown documents containing code blocks with file paths. Perfect for converting technical documentation or tutorials back into actual project files.

ファイルパス付きのコードブロックを含むMarkdownドキュメントからファイルを抽出するツールです。技術文書やチュートリアルに埋め込まれたソースコードを実際のファイルとして展開できます。

## Usage

```bash
extractmarkdown [options] <markdown_file>
```

### Options

- `-d, --directory <path>` - Output directory path (default: current directory) / 出力ディレクトリパス（デフォルト: カレントディレクトリ）
- `-f, --force` - Allow overwriting existing files / 既存ファイルの上書きを許可
- `-h, --help` - Show help message / ヘルプメッセージを表示

### Arguments / 引数

- `<markdown_file>` - Path to the markdown file to process / 処理するMarkdownファイルのパス

## Supported Formats / サポート形式

### Input Markdown Format / 入力Markdown形式

Supports code blocks in the following formats / 以下の形式のコードブロックを処理します：

````markdown
```language filepath
ファイル内容
```
````

または

````markdown
```filepath
ファイル内容  
```
````

### 例

````markdown
```javascript src/app.js
console.log("Hello World");
const message = "This will be extracted";
```

```python scripts/hello.py
def main():
    print("Hello from Python!")

if __name__ == "__main__":
    main()
```

```css styles/main.css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
}
```
````

## Examples / 使用例

```bash
# Extract to current directory / カレントディレクトリに出力
extractmarkdown tutorial.md

# Extract to specified directory / 指定したディレクトリに出力
extractmarkdown tutorial.md -d ./extracted-files

# Auto-determine output directory (creates tutorial_extracted/) / 自動ディレクトリ名生成（tutorial_extracted/ を作成）
extractmarkdown tutorial.md -d @

# Force overwrite existing files / 既存ファイルを強制上書き
extractmarkdown tutorial.md -f
```

### Output Example / 出力例

When processing the markdown examples above / 入力Markdownが上記の例の場合：

```
output/
├── src/
│   └── app.js
├── scripts/
│   └── hello.py
└── styles/
    └── main.css
```

