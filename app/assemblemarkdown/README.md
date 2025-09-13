# assemblemarkdown

ディレクトリやファイルを単一のMarkdownドキュメントに変換するユーティリティ。

## 概要

`assemblemarkdown`は、指定されたディレクトリ内のすべてのファイルを再帰的に探索し、それらの内容を適切な言語識別子付きのコードブロックとして統合された単一のMarkdownドキュメントを生成します。プロジェクトドキュメントの作成、コードレビュー資料の準備、チュートリアル作成などに非常に有用です。

## 機能

- **ディレクトリ構造の変換**: 指定されたディレクトリ内のすべてのファイルを再帰的に探索
- **ファイル内容の統合**: 各ファイルの内容を適切な言語識別子付きのコードブロックとして出力
- **バイナリファイルの除外**: テキストファイルのみを処理し、バイナリファイルは自動的にスキップ
- **Markdownデリミタ調整**: 既存のコードブロックと衝突しないよう、3個以上の適切な数のバッククォートを使用
- **改行処理**: ファイル末尾に改行がない場合、自動的に改行を追加してMarkdown形式を保証
- **ファイル一覧出力**: オプションでファイル一覧をMarkdown形式で最初に出力

## 使用法

```bash
assemblemarkdown [options] <input_directory|file> [-o output_file]
```

### オプション

- `-o, --output <file>`: 出力ファイル名を指定
- `-l, --list-files`: ファイル一覧をMarkdown形式で最初に出力
- `-h, --help`: ヘルプメッセージを表示

### 使用例

```bash
# ディレクトリをMarkdownに変換
assemblemarkdown ./my-project -o project.md

# ファイル一覧付きで出力
assemblemarkdown ./src -l -o src-overview.md

# 標準出力に出力
assemblemarkdown ./project
```


## 出力形式

生成されるMarkdownドキュメントの構造：

1. **ファイル一覧**（`-l`オプション指定時）
2. **各ファイルのセクション**：
   - ファイル名をH2見出しとして出力
   - 拡張子から判定された言語識別子付きコードブロック
   - ファイル名をコードブロックの識別子として付加

````markdown
## File List

- src/main.py
- src/utils.py

## src/main.py

```python src/main.py
#!/usr/bin/env python3
# メインファイルの内容
```

## src/utils.py

```python src/utils.py
# ユーティリティファイルの内容
```
````
