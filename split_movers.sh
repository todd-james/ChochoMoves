#!/bin/bash

# Bulk processing of candidate splitting 
# Loop to process all years and prefectures 
# James Todd - Oct '23



for i in {2009..2016}; do
    for j in {01..47}; do
        current_input="${cleandata_path}/GeocodedAddresses/${i}_$(printf "%02d" $j).csv"
        next_input="${cleandata_path}/GeocodedAddresses/$((i+1))_$(printf "%02d" $j).csv"

        now=$(date)
        st=$(date +%s)
        echo "Starting Current Year: ${i}, Prefecture ${j}___${now}" >> split_chcoho_timing.txt

        # Use GNU Parallel to run tasks in parallel
        Rscript split_candidates.R $current_input $next_input

        et=$(date +%s)
        echo "Done Current Year: ${i}, Prefecture in $((et - st))s" >> split_chcoho_timing.txt
    done
done