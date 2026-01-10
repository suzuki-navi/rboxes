# gitl

Git log with graph formatting and pretty output

## 概要

Gitコミット履歴をグラフ形式で美しくフォーマットして表示するツールです。ブランチの関係、マージ履歴、コミットの流れを視覚的に理解しやすい形で提供します。

## 使用方法

```bash
gitl [options] [commit-ish...]
```

### オプション

- `--help` - ヘルプメッセージを表示

### 引数

- `[commit-ish...]` - ログを表示するGitリファレンス（オプション）。未指定の場合は全ブランチ、タグ、リモートのログを表示

## 基本的な使用例

```bash
# 全ブランチのグラフ表示ログ
gitl

# 特定ブランチのログ
gitl main

# 複数のブランチ・タグを指定
gitl main develop v1.0.0

# 現在のブランチのみ
gitl HEAD
```

## 出力例

```
$ gitl
* 2a51183 (HEAD -> main, origin/main) add extractmarkdown
* 3c9690d update
*   21c17a8 Merge branch 'feature/user-auth'
|\  
| * a3e091e (origin/feature/user-auth) Add user authentication
| * 1688ad5 Add login form validation
|/  
* b4c5d6e Initial commit
* f7e8d9c Add project setup
*   c1d2e3f Merge pull request #10
|\  
| * 9a8b7c6 Fix critical bug in payment processing
| * 5f4e3d2 Add error handling
|/  
* 8e7d6c5 Release v1.0.0
```
