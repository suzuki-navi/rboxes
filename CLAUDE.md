# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the `rboxes` repository - a collection of dockerized command-line utilities packaged as self-extracting executables. Each tool runs in its own Docker container, providing consistent execution environments while remaining portable and easy to distribute.

## Build System

### Main Build Commands
```bash
# Build all applications
./build.sh

# Run all tests
./run-tests.sh

# Build individual app
cd app/<app_name>
./build.sh
```

### Build Process Architecture
The build system uses a sophisticated self-extracting executable pattern:

1. **Source Structure**: Apps define their logic in `src.md` (markdown with embedded code blocks)
2. **Extraction Phase**: `extractmarkdown` tool extracts code blocks to `src/` directory
3. **Self-Packing**: `rselfpack` creates self-extracting executables with embedded compressed source
4. **Runtime**: Executables extract to temp directories and run via Docker with `rdockrun`

### Core Build Components
- `lib/lib.sh`: Shared build utilities (`smart_cp`, `smart_mv`, `build_app`)
- `app/extractmarkdown/`: Extracts code blocks from markdown (Perl)
- `app/rselfpack/`: Creates self-extracting shell scripts (Perl)
- `app/rdockrun/`: Docker runner with environment and volume handling

## Architecture Patterns

### Self-Extracting Executable Flow
1. App contains compressed source code and metadata
2. On execution, extracts to temporary directory
3. Builds Docker image with content-based hash naming for caching
4. Runs container with proper volume mounts and user permissions
5. Cleans up temporary files on exit

### Environment Configuration
- `.rx.env` files provide hierarchical environment configuration
- `load-env.sh` loads variables from filesystem root to current directory
- Variables are scoped to prevent leakage between applications

### Docker Integration
- Each tool runs isolated in its own container
- User permissions preserved via `--user` flag
- Working directory mounted as volume
- `/var/run/docker.sock` mounted for Docker-in-Docker scenarios

## Directory Structure

```
app/                    # Individual applications
├── assemblemarkdown/   # Assembles markdown from multiple files
├── cal/               # Calendar utility
├── claude/            # Claude CLI wrapper
├── dailynote/         # Daily note management (Ruby)
├── extractmarkdown/   # Extract files from markdown code blocks (Perl)
├── hexdumpch/         # Hex dump with character display (Ruby)
├── jq/                # JSON processor wrapper
├── ll/                # Enhanced ls command
└── ...

bin/                   # Built self-extracting executables
lib/                   # Shared build scripts and runtime utilities
var/                   # Runtime data, old versions, and test data
```

## Application Types

The repository contains three main application patterns:

### Type 1: src.md Pattern (11 applications)
Applications that define their source in `src.md` files and use the standard build process:
- **aws**: AWS CLI tools
- **backlogexp**: Backlog export utility (Python)
- **cal**: Calendar utility
- **claude-file**: Claude file tool
- **claude**: Claude CLI wrapper
- **create-bedrock-api-key**: AWS Bedrock API key generator
- **dailynote**: Daily note management (Ruby)
- **hexdumpch**: Hex dump with character display (Ruby)
- **jq**: JSON processor wrapper
- **markdown2html**: Markdown to HTML converter (Python)
- **nkf**: Network Kanji Filter
- **office2pdf**: Office to PDF converter (Perl)
- **pdf2images**: PDF to images converter (Python)
- **yq**: YAML processor

### Type 2: Direct Executable Pattern (9 applications)
Applications where the executable is directly managed in git:
- **assemblemarkdown**: Markdown assembler
- **extractmarkdown**: Markdown code block extractor
- **gita**: Git add tool
- **gitb**: Git branch tool
- **gitl**: Git log tool
- **gits**: Git status tool
- **ll**: Enhanced ls command
- **rdockrun**: Docker runner
- **rselfpack**: Self-packing tool

### Type 3: Custom Configuration (2 applications)
Applications with unique build patterns:
- **rsealpack**: Secure script packaging tool (Rust + wrapper scripts)
- **updatebacklinks**: Backlink updater (Perl source file directly managed)

## Application Development

### Creating New Applications

1. **Create app directory**: `mkdir -p app/myapp`

2. **Create source definition** (`src.md`):
````markdown
## Dockerfile
```text Dockerfile
FROM ubuntu:22.04
COPY . /app
```

## main.sh
```bash main.sh
#!/bin/bash
# Your main application logic
```
````

3. **Build**: The build process will:
   - Extract code blocks to `src/` directory
   - Copy dependencies and help text
   - Create self-extracting executable

### Common Application Patterns

Most applications follow this structure:
- `src/Dockerfile`: Container definition
- `src/main.sh`: Entry point and argument parsing
- `src/help.txt`: Usage documentation
- Language-specific files (`.py`, `.rb`, `.pl`, etc.)

### Testing
- Individual apps can have `test/` directories with `test.sh` scripts
- Global test runner: `./run-tests.sh` finds and executes all `test.sh` files
- Tests should be self-contained and cleanup after themselves

## Runtime Environment

### Volume Mounts
Applications automatically get:
- Current working directory mounted at same path
- User home directory mounted
- Docker socket for Docker-in-Docker scenarios

### Permissions
All containers run with current user's UID/GID to maintain file ownership.

## Development Workflow

```bash
# Typical development cycle
cd app/myapp
# Edit src.md file
bash ./build.sh                    # Builds and packages
./myapp --help                     # Test the built executable
```
