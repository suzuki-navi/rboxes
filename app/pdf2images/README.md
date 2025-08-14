# pdf2images

PDF to Images converter

## Overview

This is a command-line tool that converts PDF documents to PNG image files. Each page is output as an individual image, making it suitable for creating presentation materials or converting documents to images.

PDFドキュメントをPNG画像ファイルに変換するコマンドラインツールです。各ページを個別の画像として出力し、プレゼンテーション資料の作成や文書の画像化に適しています。

## Usage

```bash
pdf2images [options] <PATH>
```

### Options

- `--help` - Display this help message

### Arguments

- `<PATH>` - Path to the PDF document to convert. The output images will be created in the `<PATH>.pages` directory with sequential numbering.

## Supported Formats

### Input Formats
- **PDF**: `.pdf`

### Output Formats
- **PNG images**: `.png`

## Basic Usage Examples

```bash
# Convert PDF to images
pdf2images ~/report.pdf
# → PNG files will be created in report.pdf.pages/ directory
```

### Output Example

```
report.pdf.pages/
├── 001.png    # Page 1
├── 002.png    # Page 2
├── 003.png    # Page 3
└── ...
```

### Image Specifications
- **Format**: PNG
- **Resolution**: 400 DPI
- **Color Space**: RGB
- **Background**: White


### Note

NOTE:
- Images are saved at 400 DPI resolution for high quality
- Page numbers are zero-padded based on total page count
- Output directory is created automatically if it doesn't exist
