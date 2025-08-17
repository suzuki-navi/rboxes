# office2pdf

Document to PDF converter

## Overview

Converts Microsoft Office documents to PDF format using LibreOffice.

Microsoft Officeドキュメント（Word、Excel、PowerPoint）をLibreOfficeを使用してPDF形式に変換するコマンドラインツールです。

## Usage

```bash
office2pdf <input_file> -o <output_file_path>      # File output / ファイル出力
office2pdf <input_file>                            # Auto-determined file output / 自動判定ファイル出力
office2pdf <input_file> -o @                       # Auto-determined file output / 自動判定ファイル出力
office2pdf <input_file> -f                         # Force overwrite / 強制上書き
```

### Options

- `-o, --output <path>` - Output file path or special values / 出力ファイルパスまたは特殊値
- `-f, --force` - Allow overwriting existing files / 既存ファイルの上書きを許可
- `--help` - Display this help message / ヘルプメッセージを表示

### Arguments

- `<input_file>` - Path to the office document to convert to PDF / PDF変換するOfficeドキュメントのパス

### Special Output Values

- `-o -` - Write to standard output (stdout) / 標準出力に書き込み
- `-o @` - Auto-determine output file path (adds .pdf to original filename) / 出力ファイルパスを自動判定（元のファイル名に.pdfを追加）

## Supported Formats

### Input Formats
- **Word**: `.doc`, `.docx`
- **Excel**: `.xls`, `.xlsx`
- **PowerPoint**: `.ppt`, `.pptx`

### Output Formats
- **PDF**: `.pdf`
