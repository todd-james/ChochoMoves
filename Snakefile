# Snakefile 
# TelAD Data Chocho Level Moves 
# From Raw Data to Chocho ID 
# James Todd - Oct '23

import glob
import os 

# Environment Variables 
envvars: 
    "rawdata_path",
    "cleandata_path"

# Paramters 
years_prefectures = [f"{x.split('/')[9]}_{x.split('/')[11].replace('.txt', '')}" for x in glob.glob(f"{os.environ['rawdata_path']}/*/new/*.txt")]

# Rules 
rule all: 
    input: 
        "done.txt"

rule clean_input: 
    input: 
        "clean_addresses.py", 
        f"{os.environ['rawdata_path']}/{{year}}/new/{{prefecture}}.txt"
    output: 
        temporary(f"{os.environ['cleandata_path']}/InputAddresses_Clean/{{year}}_{{prefecture}}.txt")
    shell: 
        "python {input} {output}"

rule geocode_address: 
    input: 
        "geolonia_addrgeocode.js", 
        f"{os.environ['cleandata_path']}/InputAddresses_Clean/{{year}}_{{prefecture}}.txt"
    output:
        f"{os.environ['cleandata_path']}/GeocodedAddresses/{{year}}_{{prefecture}}.csv"
    shell: 
        "node {input} {output}"

# Probably need some rule here to reformat geocoded addresses back onto the raw data with names/numbers 
# Also need to consider how we might try rectify those that were unsuccessful (level 1 or 2) by modifying the addresses
# Finally need to assign chocho using point in polygon on the coordinates 

# rule improve_geocoding: 

# rule rerun_geocoding: 

# rule tidy_outputs: 

rule all_geocoded: 
    input: 
        expand(f"{os.environ['cleandata_path']}/GeocodedAddresses/{{year_prefecture}}.csv", year_prefecture = years_prefectures)
    output:
        "done.txt"
    shell:
        "touch {output}"


