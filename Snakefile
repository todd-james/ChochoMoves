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
years = list(set([f"{x.split('/')[9]}" for x in glob.glob(f"{os.environ['rawdata_path']}/*/new/*.txt")]))
prefectures = list(set([f"{x.split('/')[11].replace('.txt', '')}" for x in glob.glob(f"{os.environ['rawdata_path']}/*/new/*.txt")]))

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

# Generate rules for each prefecture
for prefecture in prefectures:
    rule: 
        name: 
            f"deduplicate_within_prefecture_{prefecture}"
        input: 
            expand(f"{os.environ['cleandata_path']}/InputAddresses_Clean/{{year}}_{prefecture}.txt", year=years)
        output: 
            f"{os.environ['cleandata_path']}/DeduplicatedWithinPrefecture/{prefecture}.txt"
        shell: 
            "python deduplicate_within_prefecture.py {output} {input}"
            
rule geocode_address: 
    input: 
        "geolonia_addrgeocode.js", 
        f"{os.environ['cleandata_path']}/DeduplicatedWithinPrefecture/{{prefecture}}.txt"
    output:
        f"{os.environ['cleandata_path']}/GeocodedAddresses/{{prefecture}}.csv"
    shell: 
        "node {input} {output}"

rule assign_geocode_outputs: 
    input: 
        "results_to_raw.py", 
        f"{os.environ['rawdata_path']}/{{year}}/new/{{prefecture}}.txt",
        f"{os.environ['cleandata_path']}/GeocodedAddresses/{{prefecture}}.csv"
    output: 
        f"{os.environ['cleandata_path']}/GeocodedAddresses/{{year}}_{{prefecture}}.csv"
    shell: 
        "python {input} {output}"

# rule split_candidates: 
#     input: 
#         "split_candidates.R", 
#         f"{os.environ['cleandata_path']}/GeocodedAddresses/{{year}}_{{prefecture}}.csv", 
#         f"{os.environ['cleandata_path']}/GeocodedAddresses/{{year+1}}_{{prefecture}}.csv"
#     output: 
#         f"{os.environ['cleandata_path']}/GeocodedAddresses/Split/{{year}}_{{prefecture}}_nomove.csv", 
#         f"{os.environ['cleandata_path']}/GeocodedAddresses/Split/{{year}}_{{prefecture}}_movein.csv", 
#         f"{os.environ['cleandata_path']}/GeocodedAddresses/Split/{{year}}_{{prefecture}}_moveout.csv"
#         f"{os.environ['cleandata_path']}/GeocodedAddresses/Split/{{year}}_{{prefecture}}_other.csv"
#     shell: 
#         "Rscript {input} {output}"

rule all_geocoded: 
    input: 
        expand(f"{os.environ['cleandata_path']}/GeocodedAddresses/Split/{{year_prefecture}}_other.csv", year_prefecture = years_prefectures)
    output:
        "done.txt"
    shell:
        "touch {output}"


