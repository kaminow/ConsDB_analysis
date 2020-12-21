#!/bin/bash

# Number of simultaneous downloads (change to fit your machine)
n_simul=10
url_file=$1
out_dir=$2

urls=($(cat $url_file))
n_urls=${#urls[@]}

n_complete=0
while [[ n_complete -lt $n_urls ]]; do
    # Calculate how many files to download in this round of downloads
    n_left=$(($n_urls - $n_complete))
    if [[ $n_left -lt $n_simul ]]; then
        n_to_add=$n_left
    else
        n_to_add=$n_simul
    fi

    for i in $(seq $n_complete $(($n_to_add + $n_complete - 1))); do
        IFS=',' read -ra line_info <<< ${urls[i]}

        mkdir -p ${out_dir}/${line_info[1]}
        out_fn=${out_dir}/${line_info[1]}/$(basename ${line_info[0]})
        wget -O $out_fn ${line_info[0]} && echo $(basename ${line_info[0]}) &
    done

    wait
    n_complete=$((n_complete + $n_to_add))
done