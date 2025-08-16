import argparse
import os
import re
import textwrap

import markdown

####################################################################################################

def main():
    parser = argparse.ArgumentParser(description='Convert a file to HTML')
    parser.add_argument('source_path', type=str, nargs='?', default=None, help='The path to the input file or directory')
    parser.add_argument('-o', '--output-dir', type=str, help='Output directory for HTML files')
    parser.add_argument('-f', '--force', action='store_true', help='Force overwrite existing files')

    args = parser.parse_args()

    # 入力がディレクトリの場合は -o オプションが必須
    if args.source_path and os.path.isdir(args.source_path):
        if not args.output_dir:
            parser.error("Output directory (-o) is required when input is a directory")
        process_directory(args.source_path, args.output_dir, args.force)
    else:
        to_html(args.source_path, args.output_dir, args.force)



# -o オプションでディレクトリが指定されたら、そのディレクトリに同名のファイルでHTMLを出力するように -o オプションを実装する。入力となるMarkdownファイルが foo.md だったら -o で指定されたディレクトリの中に foo.html という名前で出力する。

# コマンドラインパラメータがファイルパスの代わりにディレクトリを指定されたら、そのディレクトリの中に含まれるすべてのMarkdownファイルを対象にする。その場合は -o オプションを必須とする。
# 例
# foo_dir をパラメータに指定し、その名前のディレクトリの中が
# foo_dir/a.md
# foo_dir/sub/b.md
# という構成で、そして -o bar_dir を指定した場合
# bar_dir/a.html
# bar_dir/sub/b.html
# を作成することとする。

# いずれの場合も作成しようとするファイルがすでに存在していた場合はそのファイルをスキップし、残りを処理したうえで、プロセスをエラー終了とする。

# -f オプションを新たに実装する。 -f が指定されたら、ファイルが存在していても上書きで処理する。

def process_directory(input_dir, output_path, force_overwrite):
    """ディレクトリ内のすべてのMarkdownファイルを再帰的に処理"""
    skipped_files = []
    
    for root, dirs, files in os.walk(input_dir):
        for filename in files:
            if filename.lower().endswith('.md'):
                input_path = os.path.join(root, filename)
                
                # 相対パスを計算してディレクトリ構造を保持
                rel_path = os.path.relpath(input_path, input_dir)
                html_filename = rel_path[:-3] + '.html'  # .md を .html に置換
                output_file = os.path.join(output_path, html_filename)
                
                # 出力ディレクトリを作成
                output_subdir = os.path.dirname(output_file)
                if output_subdir and not os.path.exists(output_subdir):
                    os.makedirs(output_subdir)
                
                # ファイル存在チェック
                if os.path.exists(output_file) and not force_overwrite:
                    print(f"Skipping {input_path} -> {output_file} (file exists)")
                    skipped_files.append(output_file)
                    continue
                
                try:
                    convert_file(input_path, output_file)
                    print(f"Converted {input_path} -> {output_file}")
                except Exception as e:
                    print(f"Error converting {input_path}: {e}")
                    skipped_files.append(input_path)
    
    if skipped_files:
        print(f"Process completed with errors. {len(skipped_files)} files were skipped.")
        exit(1)


def convert_file(input_path, output_path):
    """単一ファイルをMarkdownからHTMLに変換"""
    with open(input_path, 'rb') as file:
        file_binary_content = file.read()
    
    file_text_content = convert_to_text_if_text_file(file_binary_content)
    if file_text_content is None:
        raise ValueError("The file is not a text file.")
    
    html = markdown_to_html(file_text_content)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html)


def to_html(source_path, output_path=None, force_overwrite=False):
    if source_path is None:
        file_binary_content = os.sys.stdin.buffer.read()
        input_filename = "stdin"
    else:
        with open(source_path, 'rb') as file:
            file_binary_content = file.read()
        input_filename = os.path.basename(source_path)

    file_text_content = convert_to_text_if_text_file(file_binary_content)
    if file_text_content is None:
        raise ValueError("The file is not a text file.")

    html = markdown_to_html(file_text_content)

    if output_path:
        # 出力ディレクトリが指定された場合
        if not os.path.exists(output_path):
            os.makedirs(output_path)
        
        # 拡張子を .html に変更
        if input_filename.lower().endswith('.md'):
            html_filename = input_filename[:-3] + '.html'
        else:
            html_filename = input_filename + '.html'
        
        output_file = os.path.join(output_path, html_filename)
        
        # ファイル存在チェック
        if os.path.exists(output_file) and not force_overwrite:
            print(f"Error: File '{output_file}' already exists. Use -f to force overwrite.")
            exit(1)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f"Converted to {output_file}")
    else:
        # 標準出力に出力（従来の動作）
        os.sys.stdout.write(html)
        os.sys.stdout.flush()

####################################################################################################

def markdown_to_html(markdown_text: str) -> str:
    markdown_text = _modify_markdown_for_html(markdown_text)
    markdown_text = replace_md_links(markdown_text)

    template_path = os.path.join(os.path.dirname(__file__), 'template.html')
    with open(template_path, 'r', encoding='utf-8') as f:
        template = f.read()
    
    markdown_html = markdown.markdown(markdown_text, extensions=['fenced_code', 'tables'])
    html = template.replace('{content}', markdown_html)
    return html


def _modify_markdown_for_html(markdown_text: str) -> str:
    lines = content_to_lines(markdown_text)

    code_block_marker = None
    lines2 = []
    for i, line in enumerate(lines):
        if code_block_marker:
            if line.startswith(code_block_marker):
                code_block_marker = None
            lines2.append(line)
            continue
        if line.startswith("```"):
            backquote_count = len(line) - len(line.lstrip('`'))
            code_block_marker = "`" * backquote_count
            lines2.append(line)
            continue
        if lines2 and lines2[-1].strip():
            if not lines2[-1].strip().startswith("-") and line.strip().startswith('-'):
                lines2.append('')
        if lines2 and lines2[-1].strip():
            if line and not line.strip().startswith('-') and not line.strip().startswith('|'):
                lines2[-1] += '<br>'
        lines2.append(line)
    markdown_text = lines_to_content(lines2)

    return markdown_text


# 拡張子 .md を .html に置換（アンカー保持）
def replace_md_links(text):
    return re.sub(r'\[([^\]]+)\]\(([^)]+?)\.md(#.*?)?\)', r'[\1](\2.html\3)', text)


####################################################################################################

def lines_to_content(lines: list[str]) -> str:
    if len(lines) == 0:
        return ""
    lines = _drop_empty_lines(lines)
    return "\n".join(lines) + "\n"


def content_to_lines(content: str) -> list[str]:
    if content == "":
        return []
    lines = content.split("\n")
    lines = _drop_empty_lines(lines)
    return lines


def _drop_empty_lines(lines: list[str]) -> list[str]:
    lines = [line.rstrip() for line in lines]
    while len(lines) > 0 and lines[-1] == "":
        lines = lines[:-1]
    while len(lines) > 0 and lines[0] == "":
        lines = lines[1:]
    return lines

####################################################################################################

def convert_to_text_if_text_file(file_content: bytes) -> str | None:
    if b"\x00" in file_content:
        return None
    size = len(file_content)
    utf8_text, utf8_error_count = _decode_char_encoding(file_content, "utf-8")
    if utf8_error_count == 0:
        return utf8_text
    eucjp_text, eucjp_error_count = _decode_char_encoding(file_content, "euc-jp")
    if eucjp_error_count == 0:
        return eucjp_text
    min_error_count = min(utf8_error_count, eucjp_error_count)
    if min_error_count >= size // 100:
        return None
    if min_error_count == utf8_error_count:
        return utf8_text
    if min_error_count == eucjp_error_count:
        return eucjp_text
    return None


def _decode_char_encoding(content: bytes, encoding: str) -> tuple[str, int]:
    result = content.decode(encoding, errors="replace")
    count_replacement_chars = result.count("�")
    return result, count_replacement_chars

####################################################################################################


####################################################################################################

main()
