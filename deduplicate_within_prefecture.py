# TelAd Address Data Cleaning 
# Remove Duplicated Addresses across years
# James Todd - Oct '23

import sys
import pandas as pd

def deduplicate_within_prefecture(input_files, output_file):
    # Initialize an empty DataFrame
    combined_data = pd.DataFrame(columns=['address'])

    for input_file in input_files:
        data = pd.read_csv(input_file, names=['address'])
        combined_data = pd.concat([combined_data, data])

    # Deduplicate addresses within the same prefecture
    unique_addresses = combined_data.drop_duplicates(subset='address')

    # Save unique addresses to the output file
    unique_addresses.to_csv(output_file, header=False, index=False, columns=['address'])

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python deduplicate_within_prefecture.py output_file input_file1 input_file2 ... input_fileN")
        sys.exit(1)

    output_file = sys.argv[1]
    input_files = sys.argv[2:]
    deduplicate_within_prefecture(input_files, output_file)
