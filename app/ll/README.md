# ll

Enhanced directory listing and file viewing utility

## Overview

A unified tool for displaying directory listings and viewing file contents. It shows detailed file listings for directories and file contents for files, with automatic paging for easy viewing.

ディレクトリリストの表示とファイル内容の閲覧を統合したツールです。ディレクトリの場合は詳細なファイル一覧を、ファイルの場合は内容を表示し、出力をページングして見やすく表示します。

## RBoxes-specific Features

- **Unified display**: Handle both directories and files with the same command
- **Automatic paging**: Long output is automatically paged with `less`
- **Multiple path support**: Separate display with dividers for multiple paths

## Usage

```bash
# Standard usage
ll [options] [PATH...]
```

### Options

- `--help` - Display help message

### Arguments

- `[PATH...]` - One or more files or directories to display. Defaults to current directory if omitted

## Operation Specifications

### For Directories
```bash
ll /path/to/directory
# Executed command: ls -alF --color --time-style="+%Y-%m-%d %H:%M:%S"
```

### For Files
```bash
ll file.txt
# Executed command: cat file.txt
```

### For Multiple Paths
```bash
ll dir1/ file1.txt dir2/
# Display content with dividers for each path
```

### Utilizing Paging Features

Long directory listings or large file contents are automatically displayed with `less`

長いディレクトリリストや大きなファイル内容は自動的に`less`で表示されます。

## Output Examples

### Single Directory Display
```
$ ll src/
total 48
drwxr-xr-x  3 user user  4096 2024-01-15 14:30 ./
drwxr-xr-x 25 user user  4096 2024-01-15 14:25 ../
-rw-r--r--  1 user user  1543 2024-01-15 14:30 main.py
-rwxr-xr-x  1 user user  8192 2024-01-15 14:30 script.sh*
drwxr-xr-x  2 user user  4096 2024-01-15 14:30 utils/
```

### Multiple Path Display
```
$ ll README.md src/
####################################################################################################
# README.md
####################################################################################################
# My Project

This is a sample project...

####################################################################################################
# src/
####################################################################################################
total 16
drwxr-xr-x  2 user user 4096 2024-01-15 14:30 ./
drwxr-xr-x 25 user user 4096 2024-01-15 14:25 ../
-rw-r--r--  1 user user 1543 2024-01-15 14:30 main.py
```

## Technical Specifications

- **Execution environment**: Direct execution (non-Docker)
- **Dependencies**: ls, cat, less（Standard Unix tools）

## Less Command Options

- `-X`: Don't clear screen on exit
- `-F`: Quit immediately if content fits on one screen
- `-R`: Properly display ANSI color escape sequences

## Future TODOs

The following feature improvements are under consideration:

- **Improved binary file handling**: Currently displayed directly with cat; considering proper binary file detection and display methods
- **Support for non-UTF-8 encodings**: Currently fixed to UTF-8; considering support for other character encodings
- **Syntax highlighting feature**: Introduction of syntax highlighting based on file extensions
