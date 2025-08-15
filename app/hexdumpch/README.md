# hexdumpch

A UTF-8 compatible hexdump utility that displays binary data in hexadecimal format with properly aligned UTF-8 characters.

UTF-8対応のhexdumpユーティリティ。バイナリデータを16進数表示し、対応するUTF-8文字を適切に配置して表示します。

## Features

- **UTF-8 Character Support**: Properly handles multibyte characters and aligns them with HEX display positions
- **Line Numbering**: Shows 4-digit line numbers for lines separated by newline characters
- **Character Boundary Awareness**: Respects UTF-8 character boundaries when splitting data
- **Newline Control Option**: Can disable automatic line breaking on newline characters
- **Width Specification**: Customizable number of bytes per line

## Usage

```bash
hexdumpch [options] [file]
```

### Options

- `-w, --width WIDTH`: Number of bytes per line (default: 16)
- `-n, --no-break-on-newline`: Do not break lines on newline (0x0a) characters
- `-h, --help`: Show help message

### Examples

```bash
# Display hexdump of a file
hexdumpch sample.txt

# Display hexdump from stdin
echo "Hello World" | hexdumpch

# Set width to 8 bytes
hexdumpch -w 8 sample.txt

# Disable line breaking on newlines
hexdumpch -n sample.txt
```

## Output Format

### Normal Display (with newline breaking)
```
   1:> 000000  48 65 6c 6c 6f 20 57 6f 72 6c 64 0a
               H  e  l  l  o     W  o  r  l  d
   2:> 00000c  48 65 6c 6c 6f 0a
               H  e  l  l  o
```

### No Newline Breaking (-n option)
```
     000000  48 65 6c 6c 6f 20 57 6f 72 6c 64 0a 48 65 6c 6c
            H  e  l  l  o     W  o  r  l  d      H  e  l  l
     000010  6f 0a
             o
```

### Display Elements

- **Line Number**: 4-digit number for logical lines separated by newlines
- **Marker**: `>` marker indicating line start
- **Offset**: Byte position (6-digit hexadecimal)
- **HEX Values**: Hexadecimal representation of byte data
- **UTF-8 Characters**: Corresponding UTF-8 characters (control characters shown as `.`)
