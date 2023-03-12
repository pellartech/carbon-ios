#!/usr/bin/env python3
import os
import glob
import re
import argparse

def replace_strings_in_file(file_path):
    print(f"Replacing strings in strings file: {file_path}")

    brand_names = ['firefoksa', 'firefoxen', 'firefoxu', 'firefoxe', 'firefoxban', 'firefoksie', 'firefox', 'mozilla']
    new_lines = []

    with open(file_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        parts = line.split('=')
        if len(parts) > 1:
            key, value = parts[0], parts[1]

            for name in brand_names:
                value = re.sub(name, 'Carbon', value, flags=re.IGNORECASE)

            new_lines.append(f"{key}={value}")
        elif line.strip().endswith(';'):
            for name in brand_names:
                line = re.sub(name, 'Carbon', line, flags=re.IGNORECASE)
            new_lines.append(line)
        else:
            new_lines.append(line)

    # writing to file
    with open(file_path, 'w') as file:
        file.writelines(new_lines)


def replace_strings_in_directory(directory_path):
    for file_path in glob.glob(f"{directory_path}/**/*.strings", recursive=True):
        if not "Carbon" in file_path and file_path.endswith(".strings"):
            replace_strings_in_file(file_path)
        else:
            print(f"File extension not valid: {file_path}")


if __name__ == "__main__":
    folders = ['Client', 'Extensions', 'Shared']
    for folder in folders:
        replace_strings_in_directory(folder)