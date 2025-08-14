# office2pdf

Document to PDF converter

## Overview

Converts Microsoft Office documents to PDF format.

Microsoft Officeドキュメント（Word、Excel、PowerPoint）をPDF形式に変換するコマンドラインツールです。

## Usage

```bash
office2pdf [options] <PATH>
```

### Options

- `--help` - Display this help message

### Arguments

- `<PATH>` - Path to the office document to convert to PDF.
             The output PDF will be created in the same directory
             with the same filename but with .pdf extension.

## Supported Formats

### Input Formats
- **Word**: `.doc`, `.docx`
- **Excel**: `.xls`, `.xlsx`
- **PowerPoint**: `.ppt`, `.pptx`

### Output Formats
- **PDF**: `.pdf`

## Basic Usage Examples

```bash
office2pdf presentation.pptx
# converts presentation.pptx to presentation.pptx.pdf
```

## Output File Naming Convention

The converted PDF file will be created alongside the original file with the original filename plus ".pdf" extension.

- `document.docx` → `document.docx.pdf`
- `report.xlsx` → `report.xlsx.pdf`
- `presentation.pptx` → `presentation.pptx.pdf`

## Technical Specifications

- **Conversion Engine**: LibreOffice

