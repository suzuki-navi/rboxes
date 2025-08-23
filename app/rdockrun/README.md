# rdockrun

A utility for building and running Docker containers from Dockerfiles or directories.

## Overview

`rdockrun` allows you to quickly run commands inside Docker containers without manually building images. It automatically builds an image from a Dockerfile or directory and executes commands within the resulting container.

## Usage

```bash
rdockrun [-r] [--debug] [-v HOST:CONT[:MODE]]... [-p HOSTPORT:CONTPORT]... <Dockerfile|DIR> [CMD...]
```

### Options

- `-r`: Disable custom ENTRYPOINT for input file handling
- `--debug`: Enable debug output
- `-v HOST:CONT[:MODE]`: Specify volume mounts
- `-p HOSTPORT:CONTPORT`: Specify port mappings

### Notes

- Only `-r`, `-v`, `-p` and `--debug` options are accepted
- The first non-option argument must be a file or directory
- If a file is given, it is treated as a Dockerfile
- If a directory is given, all its contents are copied as the build context
- Image name is derived from a hash of the contents of the build context
- When no command is specified, a shell is started

### Examples

```bash
# Run 'ls' command using a Dockerfile
rdockrun Dockerfile ls

# Mount the current directory and run 'ls -la' using a directory as context
rdockrun -v "$(pwd):$(pwd)" foo/ ls -la
```

## Features

- Automatically builds Docker images from Dockerfiles or directories
- Handles stdin/stdout/stderr and TTY properly
- Caches images based on content hash for better performance
- Preserves the current user's UID/GID and working directory
- Preserves environment variables like HOME and timezone

## Requirements

- Docker
- Bash
- Standard Unix tools (find, sort, sha256sum)
