# RBoxes

A collection of dockerized command-line utilities packaged as self-extracting executables. Each tool runs in its own Docker container, providing consistent execution environments across different systems while remaining easy to distribute and use.

自己展開実行ファイルとしてパッケージ化されたコマンドラインユーティリティのコレクションです。各ツールは独自のDockerコンテナで実行されます。

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/suzuki-navi/rboxes.git
cd rboxes

# Build all tools
bash ./build.sh
```

### Usage
After building, add the `bin/` directory to your PATH:

```bash
# Add RBoxes tools to PATH
export PATH="$(pwd)/bin:$PATH"

# Or for permanent setup, add to your shell profile
echo 'export PATH="$HOME/path/to/rboxes/bin:$PATH"' >> ~/.bashrc
```

## 🛠️ Development

### Architecture
- **Self-extracting executables**: Each tool bundles its complete Docker context
- **Content-based caching**: Docker images are tagged with content hashes for efficient rebuilds
- **Environment inheritance**: `.rx.env` files provide configuration across the filesystem hierarchy
- **Consistent entry points**: Standardized Docker entry scripts handle permissions and environment

### Building Applications

#### Build All
```bash
bash ./build.sh
```

#### Build Individual App
```bash
cd app/backlogexp
bash ./build.sh
```

## 📋 Requirements

- **Docker**: For containerized execution
- **Bash**: For build scripts and runtime
- **Standard Unix tools**: `sha256sum`, `mktemp`, etc.

## 📄 License

[License information to be added]
