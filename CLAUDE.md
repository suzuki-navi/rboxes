# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the `rboxes` repository - a collection of dockerized command-line utilities and tools packaged as self-extracting executables. Each tool is designed to run in its own Docker container with consistent build patterns and environment handling.

## Build System

### Main Build Command
```bash
./build.sh
```
This builds all applications in the `app/` directory and copies executables to `bin/`.

### Individual App Builds
```bash
cd app/<app_name>
./build.sh
```
Each app has its own build script generated from `lib/build-template.sh`.

### Build Process
- Uses `lib/build-template.sh` as a template for individual app build scripts
- Creates self-extracting executables that bundle the entire Docker context
- Executables include embedded help text and compressed source code
- Docker images are built with content-based naming for caching efficiency

## Architecture

### Directory Structure
```
app/                    # Individual applications
├── backlogexp/        # Backlog project export tool (Python)
├── claude/           # Claude CLI wrapper
├── extractmarkdown/  # Extract files from markdown code blocks (Perl)
├── office2pdf/       # Office document to PDF converter (Python + LibreOffice)
├── pdf2images/       # PDF to images converter (Python)
├── jq/               # JSON processor wrapper
├── yq/               # YAML processor wrapper
└── ...

bin/                   # Built executables
lib/                   # Shared build scripts and Docker entry points
```

### Self-Extracting Executable Pattern
Each app follows this pattern:
1. Self-extracting shell script contains compressed source code
2. Runtime extraction to temporary directory
3. Docker build and run with content-based image naming
4. Cleanup on exit

### Docker Integration
- `entry2.sh`: Docker runner with volume mounts and permission handling  
- `entry3.sh`: Environment loader and main script executor
- `load-env.sh`: Hierarchical `.rx.env` file loading from filesystem tree
- `write-env.sh`: Environment variable persistence

## Development Workflow

### Adding New Applications
1. Create directory in `app/<new_app>/`
2. Add `src/docker/Dockerfile` 
3. Add `src/docker/entry.sh` as entry point
4. Add `src/main.sh` for main logic
5. Add `src/help.txt` for usage documentation
6. Run `./build.sh` to generate build script and executable

### Environment Configuration
- `.rx.env` files provide environment variables
- Loaded hierarchically from filesystem root to working directory
- Use `RX_VERBOSE=1` for debug output during builds and execution

### Docker Considerations
- Images are tagged with content hash for efficient caching
- Each app runs with current user permissions via `--user` flag
- Working directory and volumes are preserved in container
- `/var/run/docker.sock` is mounted for Docker-in-Docker scenarios

## Common Development Commands

```bash
# Build all applications
./build.sh

# Build specific application  
cd app/backlogexp && ./build.sh

# Run with debug output
RX_VERBOSE=1 ./bin/claude --help

# Test self-extraction without Docker
head -n 100 ./bin/claude  # View embedded help and script structure
```