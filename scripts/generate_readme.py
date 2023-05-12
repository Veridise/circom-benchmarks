import os
import json
import argparse

def process_directory(directory):
    """
    Recursively process the provided directory and generate README.md files for directories containing test.json.

    Args:
        directory (str): The root directory to start processing.
    """
    for root, dirs, files in os.walk(directory):
        if 'test.json' in files:
            json_file = os.path.join(root, 'test.json')
            generate_readme(json_file)

def generate_readme(json_file):
    """
    Generate a README.md file based on the provided JSON file.

    Args:
        json_file (str): The path to the JSON file.
    """
    with open(json_file, 'r') as file:
        data = json.load(file)
    directory = os.path.dirname(json_file)
    readme_file = os.path.join(directory, 'README.md')

    try:
        # Create the README content
        readme_content = f"# {data['id']}\n\n"
        readme_content += f"Source: {data['source']}\n\n"
        readme_content += f"Project URL: {data['project_url']}\n\n"
        readme_content += f"Commit: {data['commit']}\n\n"
        readme_content += f"Internal: {data['internal']}\n\n"
        readme_content += f"Synthetic: {data['synthetic']}\n\n"

        for test in data['tests']:
            readme_content += f"## {test['id']}\n\n"
            readme_content += f"**File**: {test['file']}\n\n"
            readme_content += f"**Template**: {test['template']}\n\n"
            readme_content += f"**Main**: {test['main']}\n\n"
            readme_content += f"**Description**: {test['description']}\n\n\n"

        # Save the README file
        with open(readme_file, 'w') as file:
            file.write(readme_content)

        print(f"README.md file generated: {readme_file}")
    except KeyError as e:
        print(f"Cannot generate README.md file for {readme_file}")
        print("Keyerror: ", e)


def main():
    parser = argparse.ArgumentParser(description='Generate README.md files from test.json')
    parser.add_argument('directory', type=str, help='the directory to process')

    args = parser.parse_args()
    process_directory(args.directory)

if __name__ == '__main__':
    main()
