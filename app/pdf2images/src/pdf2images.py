import os
import sys

import pdf2image

def main():

    if len(sys.argv) != 2:
        print("Usage: office2pdf <PATH>")
        sys.exit(1)

    pdf_path = sys.argv[1]

    file_name = pdf_path.split('/')[-1]
    file_name_extension = file_name.rsplit('.', 1)[-1].lower()

    if file_name_extension != 'pdf':
        print(f"Unsupported file type: {file_name_extension}")
        sys.exit(1)

    convert_pdf_to_images(pdf_path)


def convert_pdf_to_images(pdf_path):
    print(f"Converting {pdf_path} to images...")
    images = pdf2image.convert_from_path(pdf_path, dpi=400, fmt='PNG')
    total_pages = len(images)
    page_width = len(str(total_pages))

    dir_path = f"{pdf_path}.pages"
    os.makedirs(dir_path, exist_ok=True)

    for idx, image in enumerate(images):
        image_file_path = f"{dir_path}/{idx + 1:0{page_width}d}.png"
        print(f"Saving page {idx + 1} of {total_pages} as PNG...: {image_file_path}")
        image.save(image_file_path, 'PNG')


if __name__ == "__main__":
    main()
