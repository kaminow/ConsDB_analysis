#!/bin/bash

comp_script=$1
out_dir=$2
awk_script=$3
frag_dir=$4
id_tab=$5

ind=($(cut -d, -f 1 $id_tab))
sup=($(cut -d, -f 2 $id_tab))
pop=($(cut -d, -f 2-3 $id_tab | sed 's/,/_/'))

all_sups=$(sed 's/ /\n/g' <<< ${sup[@]} | sort | uniq)
all_pops=$(sed 's/ /\n/g' <<< ${pop[@]} | sort | uniq)
all_gens=(${all_sups[@]} ${all_pops[@]})

for i in $(seq 0 $((${#ind[@]} - 1))); do
    comp_gens='homoz'
    for g in ${all_gens[@]}; do
        [[ $g != ${sup[$i]} && $g != ${pop[$i]} ]] && comp_gens="$comp_gens $g"
    done

    out=${out_dir}/${ind[$i]}/
    mkdir -p $out
    ${comp_script} ${out} ${awk_script} ${frag_dir} $comp_gens && \
    echo ${ind[$i]}
done