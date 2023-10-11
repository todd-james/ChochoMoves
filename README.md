# Japan Chochomoku Moves 

This repo contains analysis of residential moves across Japan using Telephone directory name and address data. The repo contains the data processing pipeline that takes the raw data, geocodes it and then assigns each address to a census chocho (町丁). The repo will also contain the analysis that has been used to determine whether an individual has moved or remained in the same property/chocho between each year. 

# Requirements 
- [Geolonia Japanese Address Normalizer/Geocoder](https://github.com/geolonia/normalize-japanese-addresses)
- Environment Variables: 
        - Raw data filepath (rawdata_path)
        - Clean data filepath (cleandata_path)
        - Geolonia Address API Configuration (geolonia_api)
This should be set up in a local .env file, that may look something like this: 
```
rawdata_path="<PATH>"
cleandata_path="<PATH>"
geolonia_api="<API>"
```
and can be set by running `export $(cat .env | xargs)`


# Geocoding Pipeline Execution 

To Execute this pipeline, run `snakemake -j<No. cores>`

## General Summary
1. Clean input address data by removing duplicates and unnecessary columns [clean_addresses.py](clean_addresses.py) 
2. Run [Geolonia Japanese Address Normalizer/Geocoder](https://github.com/geolonia/normalize-japanese-addresses)
3. Identify addresses where geocoding failed 
4. Re-run [Geolonia Japanese Address Normalizer/Geocoder](https://github.com/geolonia/normalize-japanese-addresses) on failed addresses
5. Combine final outputs and identify census chocho for each address 

