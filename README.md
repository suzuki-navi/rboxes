# RBoxes

A collection of dockerized command-line utilities packaged as self-extracting executables. Each tool runs in its own Docker container, providing consistent execution environments across different systems while remaining easy to distribute and use.

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd rboxes

# Build all tools
./build.sh
```

### Usage
After building, add the `bin/` directory to your PATH:

```bash
# Add RBoxes tools to PATH
export PATH="$(pwd)/bin:$PATH"

# Or for permanent setup, add to your shell profile
echo 'export PATH="$HOME/path/to/rboxes/bin:$PATH"' >> ~/.bashrc

# Now use any tool directly
backlogexp --help
office2pdf document.docx  
extractmarkdown README.md output/
```

## 📦 Available Tools

### Document Processing
- **`office2pdf`** - Convert Microsoft Office documents (Word, Excel, PowerPoint) to PDF
- **`pdf2images`** - Convert PDF documents to PNG images at high resolution
- **`extractmarkdown`** - Extract files from markdown code blocks with file paths

### Project Management
- **`backlogexp`** - Export Backlog project data to structured YAML format with comprehensive issue tracking

### Development Utilities
- **`claude`** - Claude CLI wrapper for AI assistance
- **`jq`** - JSON processor with Docker isolation
- **`yq`** - YAML processor with Docker isolation

### Git Utilities
- **`gita`** - Git add helper
- **`gitb`** - Git branch utilities
- **`gitl`** - Git log utilities
- **`gits`** - Git status utilities

### System Utilities
- **`cal`** - Calendar utility
- **`ll`** - Enhanced directory listing
- **`nkf`** - Network Kanji Filter for character encoding
- **`rselfpack`** - Self-extracting archive utilities

## 🚀 Quick Usage Examples

```bash
# Document conversion
office2pdf document.docx        # Office to PDF
pdf2images report.pdf          # PDF to images
md2html README.md > index.html  # Markdown to HTML

# Project management
export BACKLOG_API_KEY="your-key"
backlogexp PROJECT_KEY         # Export Backlog data

# Development tools
claude "Explain this code"      # AI assistance
echo '{"name":"value"}' | jq '.name'  # JSON processing

# Git workflow
gits                           # Check status
gita src/                      # Stage changes
gitb                           # View branches
gitl | head -10                # Recent commits

# System utilities
cal 2024                       # View calendar
ll /path/to/files              # List files
rselfpack project/ > deploy.sh # Create archive
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
./build.sh
```

#### Build Individual App
```bash
cd app/backlogexp
./build.sh
```

#### Debug Mode
```bash
RX_VERBOSE=1 ./build.sh
RX_VERBOSE=1 ./bin/claude --help
```

### Adding New Applications

1. **Create app structure:**
```bash
mkdir -p app/myapp/src/docker
cd app/myapp
```

2. **Required files:**
```bash
# Main logic
src/main.sh

# Docker configuration  
src/docker/Dockerfile
src/docker/entry.sh

# User documentation
src/help.txt

# Dependencies (if needed)
src/requirements.txt  # Python
```

3. **Build and test:**
```bash
../../build.sh  # Generates build.sh automatically
./build.sh      # Build your app
```

### Directory Structure
```
app/                    # Source applications
├── backlogexp/        # Backlog export tool
├── claude/           # Claude CLI wrapper  
├── extractmarkdown/  # Markdown file extractor
└── ...               

bin/                   # Built executables
lib/                   # Shared build scripts and Docker entry points
var/                   # Runtime data and dependencies
```

### Environment Configuration

Create `.rx.env` files for configuration:
```bash
# Global config
echo 'BACKLOG_SPACE=mycompany' > ~/.rx.env

# Project-specific config  
echo 'BACKLOG_API_KEY=secret123' > /path/to/project/.rx.env
```

Environment files are loaded hierarchically from filesystem root to working directory.

## 🔒 Security

- Each tool runs in isolated Docker containers
- User permissions are preserved via `--user` flag
- No root privileges required
- Environment variables are scoped to prevent leakage

## 📋 Requirements

- **Docker**: For containerized execution
- **Bash**: For build scripts and runtime
- **Standard Unix tools**: `sha256sum`, `mktemp`, etc.

## 📄 License

[License information to be added]
