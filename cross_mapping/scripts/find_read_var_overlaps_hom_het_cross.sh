#!/bin/bash

ov_script=$1
vt_dir=$2
out_dir=$3
id_tab=$4

ind=($(cut -d, -f 1 $id_tab))
sup=($(cut -d, -f 2 $id_tab))
pop=($(cut -d, -f 2-3 $id_tab | sed 's/,/_/'))

all_sups=$(sed 's/ /\n/g' <<< ${sup[@]} | sort | uniq)
all_pops=$(sed 's/ /\n/g' <<< ${pop[@]} | sort | uniq)
all_gens=(${all_sups[@]} ${all_pops[@]})

for i in $(seq 0 $((${#ind[@]} - 1))); do
    ov_gens='homoz'
    for g in ${all_gens[@]}; do
        [[ $g != ${sup[$i]} && $g != ${pop[$i]} ]] && ov_gens="$ov_gens $g"
    done

    ${ov_script} ${vt_dir}/${ind[$i]}/ ${out_dir} ${ind[$i]} $ov_gens && \
    echo ${ind[$i]}
done