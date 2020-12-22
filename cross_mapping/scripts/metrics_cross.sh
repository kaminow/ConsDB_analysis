#!/bin/bash

metrics_script=$1
out_dir=$2
in_pref=$3
out_pref=$4
id_tab=$5

ind=($(cut -d, -f 1 $id_tab))
sup=($(cut -d, -f 2 $id_tab))
pop=($(cut -d, -f 2-3 $id_tab | sed 's/,/_/'))

all_sups=$(sed 's/ /\n/g' <<< ${sup[@]} | sort | uniq)
all_pops=$(sed 's/ /\n/g' <<< ${pop[@]} | sort | uniq)
all_gens=(${all_sups[@]} ${all_pops[@]})

for i in $(seq 0 $((${#ind[@]} - 1))); do
    met_gens=''
    for g in ${all_gens[@]}; do
        [[ $g != ${sup[$i]} && $g != ${pop[$i]} ]] && met_gens="$met_gens $g"
    done

    mkdir -p ${out_dir}/${ind[$i]}/
    ${metrics_script} ${out_dir}/${ind[$i]}/ $in_pref $out_pref $met_gens && \
    echo ${ind[$i]}
done