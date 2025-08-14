# extractmarkdown

Extract files from markdown code blocks

## 概要

ファイルパス付きのコードブロックを含むMarkdownドキュメントからファイルを抽出するツールです。技術文書やチュートリアルに埋め込まれたソースコードを実際のファイルとして展開できます。

## 使用方法

```bash
extractmarkdown <markdown_file> <output_directory>
```

### 引数

- `<markdown_file>` - 処理するMarkdownファイルのパス
- `<output_directory>` - ファイルを展開する出力ディレクトリ

## サポート形式

### 入力Markdown形式

以下の形式のコードブロックを処理します：

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

#### 出力例

入力Markdownが上記の例の場合：

```bash
extractmarkdown input.md output
```

```
output/
├── src/
│   └── app.js
├── scripts/
│   └── hello.py
└── styles/
    └── main.css
```

