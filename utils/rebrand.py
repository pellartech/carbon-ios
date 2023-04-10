#!/usr/bin/env python3
import os
import glob 
import re
import argparse


def is_valid_directory(arg):
    if os.path.isdir(arg):
        return arg
    raise argparse.ArgumentTypeError("Directory does not exist: {}".format(arg))


def replace_strings_in_directory(dir_path):
    for filename in glob.glob(os.path.join(dir_path, '**/*.strings'), recursive=True):
        if filename.endswith(".strings") and "Carbon" not in filename:
            replace_strings_in_file(filename)


def replace_strings_in_file(file_path):
    print("Replacing strings in strings file {}".format(file_path))
    try:
        with open(file_path, 'r') as f:
            lines : [bytes]  = []
            try:
                lines = f.readlines()
            except:
                print('cannot read:' + file_path)
    except IOError:
        print('cannot open:' + file_path)
        return

    brandnames = ['firefoksa', 'firefoxen', 'firefoxu', 'firefoxe', 'firefoxban', 'firefoksie', 'firefox', 'mozilla']

    newlines = []
    for line in lines:
        parts = line.split('=')
        if len(parts) > 1:
            key, value = parts
            for name in brandnames:
                value = re.sub(name, 'Carbon', value, flags=re.IGNORECASE)
            newlines.append(f"{key}={value}")
        elif line.strip().endswith(';'):
            for name in brandnames:
                line = re.sub(name, 'Carbon', line, flags=re.IGNORECASE)
            newlines.append(line)
        else:
            newlines.append(line)

    with open(file_path, 'w') as f:
        f.writelines(newlines)


if __name__ == "__main__":
    folders = ['Client', 'Extensions', 'Shared']
    for folder in folders:
        replace_strings_in_directory(folder)