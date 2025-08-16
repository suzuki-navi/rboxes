# md2html

Markdown to HTML converter

## 概要

MarkdownドキュメントをHTMLファイルに変換するコマンドラインツールです。

## 使用方法

```bash
# 標準入力から変換
md2html < input.md > output.html
cat input.md | md2html > output.html

# ファイル指定（引数がある場合）
md2html input.md > output.html
```
