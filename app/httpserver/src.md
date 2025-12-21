# HTTP Server Application

A simple HTTP server for serving directories, packaged as a self-extracting Docker executable.

## Dockerfile

```text Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY server.py /app/
EXPOSE 8000
CMD ["python", "server.py"]
```

## server.py

```python server.py
#!/usr/bin/env python3
"""
Simple HTTP server for serving directories
"""
import http.server
import socketserver
import os
import sys
from pathlib import Path

# Configuration Section
PORT = int(os.getenv('PORT', 8000))
HOST = os.getenv('HOST', '0.0.0.0')
SERVE_DIR = '.'

# Custom Handler Class
class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP request handler with configurable directory"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=SERVE_DIR, **kwargs)

    def log_message(self, format, *args):
        """Custom logging format"""
        sys.stderr.write(f"[{self.date_time_string()}] {format % args}\n")

    def end_headers(self):
        """Add custom headers"""
        self.send_header('Server', 'rboxes-httpserver')
        super().end_headers()

# Main Application Logic
def main():
    """Main entry point for the HTTP server"""
    # Validate serve directory
    serve_path = Path(SERVE_DIR)
    if not serve_path.exists():
        print(f"Error: Directory '{SERVE_DIR}' does not exist", file=sys.stderr)
        sys.exit(1)

    if not serve_path.is_dir():
        print(f"Error: '{SERVE_DIR}' is not a directory", file=sys.stderr)
        sys.exit(1)

    try:
        with socketserver.TCPServer((HOST, PORT), CustomHTTPRequestHandler) as httpd:
            print(f"Serving {SERVE_DIR} at http://{HOST}:{PORT}")
            print("Press Ctrl+C to stop the server")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        sys.exit(0)
    except OSError as e:
        if e.errno == 98:  # Address already in use
            print(f"Error: Port {PORT} is already in use", file=sys.stderr)
        else:
            print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

# Entry Point
if __name__ == "__main__":
    main()
```

## main.sh

```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

show_help() {
    cat $script_dir/help.txt
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            user_args+=("$1")
            shift
            ;;
    esac
done

set -- "${user_args[@]}"

docker_opts=()
docker_opts+=("-v" "$pwd:$pwd")
docker_opts+=("-p" "8000:8000")

#$script_dir/rdockrun "${docker_opts[@]}" $script_dir python /app/server.py "$@"
$script_dir/rdockrun "${docker_opts[@]}" $script_dir bash -c "ls -al; pwd; python /app/server.py $*"
```

