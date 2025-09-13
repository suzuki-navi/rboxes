# rselfpack

Self-extracting script generator

## Overview

This tool creates self-extracting bash scripts from directories or files. The generated script embeds all files, allowing the original file structure to be recreated on any system with bash available.

ディレクトリやファイルから自己展開型のbashスクリプトを作成するツールです。生成されたスクリプトはすべてのファイルを埋め込み、どのシステムでもbashがあれば元のファイル構造を再現できます。

## Usage

```bash
rselfpack [options] [PATH]
```

### Options

- `--help` - Display this help message
- `--no-compression` - Generate script without gzip compression (larger size, but improves readability of generated script)

### Arguments

- `[PATH]` - Path to the directory or file to package. If not specified, the current directory is used. The self-extracting script is written to standard output.

## 基本的な使用例

### ディレクトリのパッケージ化
```bash
# プロジェクト全体をパッケージ化
rselfpack /path/to/myproject > myproject.sh

# 現在のディレクトリをパッケージ化  
rselfpack . > current_project.sh

# 圧縮なしでパッケージ化
rselfpack --no-compression . > ../myproject.sh
```

### 生成スクリプトの実行
```bash
# 実行権限を付与
chmod +x myproject.sh

# 現在のディレクトリに展開
./myproject.sh

# 指定したディレクトリに展開
./myproject.sh /path/to/extract/location
```

## 特徴

- **完全な移植性**: bashが利用可能などのシステムでも実行可能
- **構造保持**: 元のディレクトリ構造を維持
- **バイナリ対応**: テキストファイルとバイナリファイルの両方を自動判別・処理
- **圧縮オプション**: gzip圧縮による効率的なサイズ削減
- **確定的な順序**: ファイル順序が一定で再現可能な結果

## 生成されるスクリプトの機能

- 引数解析による展開先ディレクトリの指定

## 技術仕様

### 依存関係

#### rselfpack実行時の要件

- Perl（5.10以降推奨）
    - `Digest::SHA`, `MIME::Base64`, `IO::Compress::Gzip` - Perl 5.10以降で標準

#### 生成スクリプト実行時の要件

- `bash`
- `base64`
- `gzip`
- `mktemp`

これらは多くのLinuxディストリビューション（Ubuntu、Debian、CentOS等）で標準インストール済みです。

## 注意事項

- 生成されるスクリプトファイルは元のデータよりも大きくなります
- シンボリックリンクは追跡されず、リンク自体は保持されません
- タイムスタンプは保持されません
- ファイル権限は実行権限のみ保持されます
