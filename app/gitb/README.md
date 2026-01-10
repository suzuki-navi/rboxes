# gitb

Git branch utilities with verbose information

## 概要

Gitリポジトリのブランチ情報を詳細な情報とともに表示するツールです。ローカルブランチ、リモートブランチ、追跡関係を一覧で確認できます。

## 使用方法

```bash
gitb [options]
```

### オプション

- `--help` - ヘルプメッセージを表示

## 出力例

```
$ gitb
* main                    2a51183 [origin/main] add extractmarkdown
  feature/user-auth       1a23456 [origin/feature/user-auth: behind 2] Add login functionality
  feature/dashboard       9b87654 Add dashboard components
  hotfix/critical-bug     c4d5e6f [origin/hotfix/critical-bug] Fix critical security issue
  remotes/origin/main     2a51183 add extractmarkdown
  remotes/origin/develop  f8e7d6c Update development dependencies
  remotes/origin/staging  5a4b3c2 Prepare staging environment
```
