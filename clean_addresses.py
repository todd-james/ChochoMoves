# TelAd Address Data Cleaning 
# Remove Duplicated Addresses 
# James Todd - Oct '23

import sys
import pandas as pd

# Set input and output 
input_file = sys.argv[1]
output_file = sys.argv[2]

# Load in Raw address data 
data = pd.read_csv(input_file, names=['name', 'postcode', 'address', 'phonenumber'])

# Remove duplicates from address
unique_addresses = data.drop_duplicates(subset='address')

# Save unique addresses to txt 
unique_addresses.to_csv(output_file, header=False, index=False, columns=['address'])