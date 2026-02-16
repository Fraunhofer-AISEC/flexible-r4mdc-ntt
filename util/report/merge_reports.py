# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import os
import sys

def merge_tex_files(input_dir, output_path):
    if not os.path.exists(input_dir):
        print(f"Input directory {input_dir} does not exist.")
        return
    
    output_dir = os.path.dirname(output_path)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Create the output file if it doesn't exist
    if not os.path.exists(output_path):
        open(output_path, 'w').close()

    # Get a sorted list of .tex files in the input directory
    tex_files = sorted([f for f in os.listdir(input_dir) if f.endswith('.tex')])

    with open(output_path, 'w') as outfile:
        for filename in tex_files:
            file_path = os.path.join(input_dir, filename)
            with open(file_path, 'r') as infile:
                outfile.write(infile.read())
                outfile.write('\n')
                    
    print(f"Merged file created at {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python merge_reports.py <input_directory> <output_path>")
        sys.exit(1)

    input_directory = sys.argv[1]
    output_path = sys.argv[2]

    merge_tex_files(input_directory, output_path)