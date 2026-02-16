# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import csv
import re
import sys
import os
import argparse

def parse_report(report_path):
    data = {
        "LUT": {"Used": 0, "Fixed": 0, "Util%": 0},
        "FF": {"Used": 0, "Fixed": 0, "Util%": 0},
        "BRAM": {"Used": 0, "Fixed": 0, "Util%": 0},
        "URAM": {"Used": 0, "Fixed": 0, "Util%": 0},
        "DSP": {"Used": 0, "Fixed": 0, "Util%": 0}
    }

    with open(report_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            match = re.match(r"\|\s+(CLB LUTs\*?|CLB Registers|Slice LUTs\*?|Slice Registers|Block RAM Tile|URAM|DSPs)\s+\|\s+([\d.]+)\s+\|\s+(\d*)\s+\|\s+\d*\s+\|\s+\d*\s+\|\s+([\d.]+)\s+\|", line)
            if match:
                site_type = match.group(1).strip()
                if site_type in ["CLB LUTs", "CLB LUTs*","Slice LUTs","Slice LUTs*"]:
                    site_type = "LUT"
                elif site_type in ["CLB Registers", "Slice Registers"]:
                    site_type = "FF"
                elif site_type == "Block RAM Tile":
                    site_type = "BRAM"
                elif site_type == "DSPs":
                    site_type = "DSP" 
                used_value = match.group(2)
                fixed_value = match.group(3)
                util_value = match.group(4)         
                data[site_type]["Used"] = float(used_value) if '.' in used_value else int(used_value)
                data[site_type]["Fixed"] = float(fixed_value) if fixed_value else 0
                data[site_type]["Util%"] = float(util_value) if '.' in util_value else int(util_value)
                

    return data

def write_to_csv(data, output_path):
    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', newline='') as csvfile:
        fieldnames = ["Site Type", "Used", "Fixed", "Util%"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for site_type, values in data.items():
            row = {"Site Type": site_type, "Used": values["Used"], "Fixed": values["Fixed"], "Util%": values["Util%"]}
            writer.writerow(row)

def write_to_tex(data, output_path, base_name):
    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w') as texfile:
        for site_type, values in data.items():
            var_prefix = site_type.lower().replace(" ", "-")
            texfile.write(f"\\DefineVar{{{base_name}-{var_prefix}-used}}{{{values['Used']}}}\n")
            texfile.write(f"\\DefineVar{{{base_name}-{var_prefix}-fixed}}{{{values['Fixed']}}}\n")
            texfile.write(f"\\DefineVar{{{base_name}-{var_prefix}-util}}{{{values['Util%']}}}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse FPGA synthesis report and generate CSV and LaTeX files.')
    parser.add_argument('report_path', help='Path to the FPGA synthesis report')
    parser.add_argument('-csv', '--csv_output_path', help='Path to the output CSV file', required=False)
    parser.add_argument('-tex', '--tex_output_path', help='Path to the output LaTeX file', required=False)
    parser.add_argument('-name', help='Base name for the LaTeX variable definitions', required=True)
    
    args = parser.parse_args()

    report_path = args.report_path
    csv_output_path = args.csv_output_path
    tex_output_path = args.tex_output_path
    base_name = args.name
    
    data = parse_report(report_path)
    
    if csv_output_path:
        write_to_csv(data, csv_output_path)
        print(f"Data has been written to {csv_output_path}")
    
    if tex_output_path:
        write_to_tex(data, tex_output_path, base_name)
        print(f"Data has been written to {tex_output_path}")
