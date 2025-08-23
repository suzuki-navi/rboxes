# md2html

Markdown to HTML converter

## 概要

MarkdownドキュメントをHTMLファイルに変換するコマンドラインツールです。

## 使用方法

### 基本的な使用方法

```bash
# 標準入力から標準出力へ変換
markdown2html < input.md > output.html

# ファイル指定で標準出力へ変換
markdown2html input.md > output.html

# ディレクトリ内の全Markdownファイルを変換（-d必須）
markdown2html source_dir/ -d output_dir/
# → ディレクトリ構造を保持して .html に変換
```

### オプション

- `-d, --directory <dir>` - 出力ディレクトリを指定
- `-f, --force` - 既存ファイルを強制上書き
- `--help` - ヘルプメッセージを表示

### 引数

- `[source_path]` - 入力ファイルまたはディレクトリのパス（省略時は標準入力）
