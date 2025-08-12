import os
import sys
import subprocess
import tempfile

def main():

    # Placeholder for the actual office to pdf conversion logic
    if len(sys.argv) != 2:
        print("Usage: office2pdf <PATH>")
        sys.exit(1)

    path = sys.argv[1]

    file_name = path.split('/')[-1]
    file_name_extension = file_name.rsplit('.', 1)[-1].lower()

    if file_name_extension not in ['ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx']:
        print(f"Unsupported file type: {file_name_extension}")
        sys.exit(1)

    tmp_pdf_path = convert_office_to_pdf(path)


def convert_office_to_pdf(office_file_path):

    try:
        output_dir = os.path.dirname(office_file_path)

        # Create a temporary user directory for LibreOffice
        with tempfile.TemporaryDirectory() as temp_user_dir:
            env = os.environ.copy()
            env['HOME'] = temp_user_dir
            env['TMPDIR'] = temp_user_dir
            env['LANG'] = 'ja_JP.UTF-8'
            env['LC_ALL'] = 'ja_JP.UTF-8'
            env['JAVA_TOOL_OPTIONS'] = '-Djava.awt.headless=true'

            cmd = [
                'libreoffice',
                '--headless',
                '--invisible',
                '--nodefault',
                '--nolockcheck',
                '--nologo',
                '--norestore',
                '--convert-to', 'pdf',
                '--outdir', output_dir,
                f'-env:UserInstallation=file://{temp_user_dir}/.config/libreoffice',
                office_file_path,
            ]

            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60, env=env)

            if result.stdout:
                print(result.stdout, end='')
            if result.stderr:
                print(result.stderr, end='')

            if result.returncode == 0:
                base_name = os.path.splitext(os.path.basename(office_file_path))[0]
                pdf_path = os.path.join(output_dir, f"{base_name}.pdf")
                if not os.path.exists(pdf_path):
                    print(f"Error: PDF file not created at {pdf_path}")
                    return None
                #print(f"Successfully converted to: {pdf_path}")
                return pdf_path
            else:
                print(f"LibreOffice conversion failed: {result.stderr}")
                return None

    except subprocess.TimeoutExpired:
        print("Error: Conversion timed out after 60 seconds")
        return None
    except FileNotFoundError:
        print("Error: LibreOffice not found. Please install LibreOffice.")
        return None
    except Exception as e:
        print(f"Error during conversion: {e}")
        return None


main()
