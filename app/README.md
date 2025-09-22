# RBoxes Applications

This directory contains a collection of dockerized command-line utilities. Each tool runs in its own Docker container, providing consistent execution environments while being packaged as portable and easy-to-distribute self-extracting executables.

## Available Tools

### Original Tools

#### Text Processing & Utilities
- **assemblemarkdown** - Tool to combine multiple markdown files
- **extractmarkdown** - Extract code blocks from markdown files
- **markdown2html** - Convert Markdown files to HTML
- **hexdumpch** - Hex dump tool with character display
- **rdockrun** - Docker runtime environment management tool
- **rselfpack** - Self-extracting executable creation tool


#### Document Conversion & PDF Processing
- **office2pdf** - Convert Microsoft Office files to PDF
- **pdf2images** - Convert PDF files to image files

#### Backlog & Project Management
- **backlogexp** - Backlog project data export tool

#### Utilities
- **cal** - Calendar utility

#### System & File Management
- **ll** - Enhanced ls command

#### Git Related Tools
- **gita** - Git add shortcut
- **gitb** - Git branch shortcut
- **gitl** - Git log shortcut
- **gits** - Git status shortcut

#### Obsidian Vault Tools
- **dailynote** - Daily note management tool
- **updatebacklinks** - Automatically manage backlinks between Markdown files

### Wrapper Tools

#### Data Processing
- **jq** - JSON processor wrapper
- **yq** - YAML processor wrapper

#### Text Processing & Utilities
- **nkf** - Japanese character encoding conversion tool wrapper

#### AI
- **claude** - Claude CLI wrapper
- **claude-file** - Claude Code file-specific wrapper

#### Cloud Services
- **aws** - AWS CLI wrapper with Docker containerization

## Usage

To build individual applications:

```bash
cd <app_name>
bash ./build.sh
```
