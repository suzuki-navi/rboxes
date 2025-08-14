# gits

Git status in compact format

## 概要

Gitリポジトリの現在の状態を簡潔で読みやすい形式で表示するツールです。変更されたファイル、ステージングされたファイル、新規ファイルなどの状況を短形式で確認できます。

## 使用方法

```bash
gits [options] [path...]
```

### オプション

- `--help` - ヘルプメッセージを表示

### 引数

- `[path...]` - 状態を表示する1つ以上のパス（オプション）

## 基本的な使用例

```bash
# リポジトリ全体の状態を表示
gits

# 特定のディレクトリの状態
gits src/

# 特定のファイルの状態
gits README.md config.yaml

# 複数のパスを指定
gits src/ tests/ docs/
```

## 出力例

```
$ gits
M  src/main.py
A  src/new_feature.py
D  old_file.txt
R  old_name.py -> new_name.py
?? untracked_file.log
!! ignored_file.tmp
```

## ステータス記号の意味

### 第1文字（ステージングエリア）
- `M` - Modified（変更済み、ステージング済み）
- `A` - Added（新規追加、ステージング済み）
- `D` - Deleted（削除済み、ステージング済み）
- `R` - Renamed（リネーム済み、ステージング済み）
- `C` - Copied（コピー済み、ステージング済み）
- `U` - Unmerged（マージ未完了）

### 第2文字（作業ディレクトリ）
- `M` - Modified（変更済み、未ステージング）
- `D` - Deleted（削除済み、未ステージング）
- `?` - Untracked（未追跡）
- `!` - Ignored（除外対象）

