# rdockrun

A utility for building and running Docker containers from Dockerfiles or directories.

`docker run`の薄いラッパーです。プロジェクトの`package.json`などの依存関係を汚さず、またユーザのグローバル環境を汚さず、再現性の高い実行環境を、**1コマンド**で提供します。

## Overview / 概要

`rdockrun` allows you to quickly run commands inside Docker containers without manually building images. It automatically builds an image from a Dockerfile or directory and executes commands within the resulting container.

`rdockrun`を使うと、手動でイメージをビルドすることなく、Dockerコンテナ内でコマンドを素早く実行できます。Dockerfileまたはディレクトリからイメージを自動的にビルドし、結果のコンテナ内でコマンドを実行します。

## Features

- Automatically builds Docker images from Dockerfiles or directories
- Handles stdin/stdout/stderr and TTY properly
- Caches images based on content hash for better performance
- Preserves the current user's UID/GID and working directory
- Preserves environment variables like HOME and timezone

## Usage / 使用方法

```bash
rdockrun [-r] [--debug] [--envfile FILEPATH] [-e VAR[=VALUE]]... [-v HOST:CONT[:MODE]]... [-p HOSTPORT:CONTPORT]... <Dockerfile|DIR> [CMD...]
```

### Options / オプション

- `-r`: Disable custom ENTRYPOINT for input file handling
- `--debug`: Enable debug output
- `--envfile FILEPATH`: Load environment variables from specified file
- `-e VAR[=VALUE]`: Set environment variable (can be used multiple times)
- `-v HOST:CONT[:MODE]`: Specify volume mounts (can be used multiple times)
- `-p HOSTPORT:CONTPORT`: Specify port mappings (can be used multiple times)


- `-r`: カスタムENTRYPOINTを無効化（標準入力処理やユーザーマッピングが不要な場合）
- `--debug`: デバッグ出力を有効化（ビルド状況や実際のdocker runコマンドを表示）
- `--envfile FILEPATH`: 指定されたファイルから環境変数を読み込み（shell変数形式）
- `-e VAR[=VALUE]`: 環境変数を設定（複数回使用可能）
  - `-e VAR=VALUE`: 指定した値を設定
  - `-e VAR`: ホストの環境変数値を継承
- `-v HOST:CONT[:MODE]`: ボリュームマウント（複数回使用可能）
- `-p HOSTPORT:CONTPORT`: ポートフォワーディング（複数回使用可能）

## Key Differences from `docker run` / `docker run`との主な違い

`rdockrun` is not just a simple wrapper for `docker run`, but provides **build automation and runtime environment adjustment in a single command**:

1. **Combined Build and Execution**: Automatically builds from Dockerfile/directory before execution
2. **Content-based Image Caching**: Uses content hash for image tags, enabling zero-time rebuilds for unchanged content
3. **Automatic Environment Setup**: Preserves host UID/GID, working directory, HOME/TZ variables

`rdockrun`は単純な`docker run`のラッパーではなく、**ビルドとランタイム環境の調整をワンコマンド化**している点に意義があります：

1. **ビルドと実行の統合**: Dockerfile/ディレクトリから自動ビルドしてから実行
2. **内容ベースのイメージキャッシュ**: 内容ハッシュをタグ名に使用し、未変更時はビルド時間ゼロ
3. **自動環境設定**: ホストのUID/GID、作業ディレクトリ、HOME/TZ変数を保持

## Examples / 使用例

### Basic Usage / 基本的な使用

```bash
# Run 'ls' command using a Dockerfile
# Dockerfileを使用して'ls'コマンドを実行
rdockrun Dockerfile ls

# Mount the current directory and run 'ls -la' using a directory as context
# 現在のディレクトリをマウントし、ディレクトリをコンテキストとして'ls -la'を実行
rdockrun -v "$(pwd):$(pwd)" foo/ ls -la
```

## Requirements / 要件

- Docker
- Bash
- Standard Unix tools (find, sort, sha256sum)

## Design Goals / 設計目標

- **Project Non-invasive**: No impact on local `node_modules` or global environment
- **Reproducibility**: User ID mapping, default working directory & volumes
- **Portability**: Linux/Mac/WSL support with minimal dependencies (only `docker` required)

- **プロジェクト非侵襲**: ローカルの`node_modules`やグローバル環境に影響を与えない
- **再現性**: ユーザーIDマッピング、既定ワークディレクトリ・ボリューム
- **ポータビリティ**: Linux/Mac/WSL対応、必要最低限の依存は`docker`のみ
