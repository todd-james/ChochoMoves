# Append the results to raw data 
# Calculate proportion of successful Matches
# James Todd - Oct '23 

import sys
import os
import pandas as pd
import re

# Load raw data file
rawdata = pd.read_csv(sys.argv[1], names=['name', 'postcode', 'address', 'phonenumber'])
# Load geocoded addresses
geocoded_add = pd.read_csv(sys.argv[2])

# Join geocoded columns to raw data
combined = pd.merge(rawdata, geocoded_add, left_on='address', right_on='Input Address', how='left')

# Extract year and prefecture from the input paths
input_path = sys.argv[1]  # Assuming the first input file contains the year and prefecture
match = re.search(r'/tlad/(\d{4})/new/([^/]+)\.txt', input_path)
if match:
    year = match.group(1)
    prefecture = match.group(2)
else:
    year = "Unknown"
    prefecture = "Unknown"

# Create a summary DataFrame for year, prefecture, level, and count
summary_df = combined.groupby('Level').size().reset_index(name='count')
summary_df['year'] = year
summary_df['prefecture'] = prefecture
summary_df = summary_df[['year', 'prefecture', 'Level', 'count']]

# Save the summary statistics in a central file (append mode to avoid overwriting)
summary_file = "/Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/Geocoding_Summary.csv"
if not os.path.exists(summary_file):
    summary_df.to_csv(summary_file, index=False)
else:
    summary_df.to_csv(summary_file, index=False, mode='a', header=False)

# Save the merged data to a CSV file
combined.to_csv(sys.argv[3], index=False)
