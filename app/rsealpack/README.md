# rsealpack - Secure Script Packaging Tool

A secure tool for encrypting script files and generating self-contained executables that can decrypt and execute scripts at runtime while ensuring interpreter integrity.

## Features

- **Multi-language Support**: Automatically detects and supports Python, Bash, Perl, Ruby, PHP, and Node.js scripts
- **AES-256-GCM Encryption**: Industry-standard authenticated encryption for script content protection
- **Interpreter Verification**: SHA-256 hash verification prevents execution with tampered interpreters
- **Supply Chain Protection**: Validates interpreter binaries to prevent supply chain attacks
- **Memory-safe Execution**: Uses pipes to avoid writing decrypted content to disk

## Quick Start

```bash
# Set encryption password
export RSEALPACK_PASS="your_secure_password"

# Encrypt and package a script
./rsealpack script.py -o secure_script --image python:3.11 --binname python

# Execute the secure binary
./secure_script
```

## Usage

### Basic Syntax
```bash
rsealpack <script_file> -o <output> --image <docker_image> --binname <interpreter>
```

### Options

- `-o, --output <path>`: Output binary path (required)
- `--image <name>`: Docker image for interpreter verification (required)  
- `--binname <name>`: Interpreter binary name (required)
- `-f, --force`: Overwrite existing output file
- `--help`: Show help information

### Environment Variables

- `RSEALPACK_PASS`: Encryption/decryption password (required)

## Examples

### Python Script
```bash
export RSEALPACK_PASS="my_secret_key"
./rsealpack app.py -o secure_app --image python:3.11 --binname python3
./secure_app
```

### Bash Script  
```bash
export RSEALPACK_PASS="bash_password"
./rsealpack deploy.sh -o secure_deploy --image ubuntu:22.04 --binname bash
./secure_deploy
```

### Perl Script
```bash
export RSEALPACK_PASS="perl_key"
./rsealpack process.pl -o secure_process --image debian:bookworm --binname perl
./secure_process
```

## How It Works

1. **Script Analysis**: Detects interpreter requirements from file extension
2. **Interpreter Verification**: Fetches interpreter path and SHA-256 hash from specified Docker image
3. **Encryption**: Encrypts script content using AES-256-GCM with scrypt key derivation
4. **Code Generation**: Generates Rust source code with embedded encrypted script
5. **Compilation**: Compiles Rust code into self-contained executable
6. **Runtime**: Executable verifies interpreter integrity and decrypts script for execution

## Security Model

### Encryption
- **Algorithm**: AES-256-GCM (authenticated encryption)
- **Key Derivation**: scrypt with configurable parameters
- **Authentication**: Built-in authentication prevents tampering

### Interpreter Verification
- **Path Validation**: Verifies interpreter is at expected absolute path
- **Hash Verification**: SHA-256 hash prevents execution with modified interpreters
- **Supply Chain Protection**: Detects compromised interpreter binaries

### Runtime Security
- **Memory Protection**: Decrypted content only exists in memory pipes
- **No Disk Writes**: Avoids temporary file creation
- **Process Isolation**: Clean separation between encryption and execution

## Requirements

- Docker (for interpreter verification and compilation)
- Bash 4.0+ 
- Standard Unix utilities (mktemp, xxd, sha256sum)

## Supported Interpreters

| Language | Default Interpreter | File Extensions |
|----------|-------------------|-----------------|
| Python   | python            | .py             |
| Bash     | bash              | .sh             |
| Perl     | perl              | .pl             |
| Ruby     | ruby              | .rb             |
| PHP      | php               | .php            |
