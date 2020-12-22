#!/bin/bash

map_script=$1
star=$2
reads_dir=$3
gen_dir=$4
out_base=$5
id_tab=$6
ln_dir=$7
shift 7
gens=$@

ind=($(cut -d, -f 1 $id_tab))
sup=($(cut -d, -f 2 $id_tab))
pop=($(cut -d, -f 2-3 $id_tab | sed 's/,/_/'))

for i in $(seq 0 $((${#ind[@]} - 1))); do
    map_gens=''
    for g in $gens; do
        [[ $g != ${sup[$i]} && $g != ${pop[$i]} ]] && map_gens="$map_gens $g"
    done

    mkdir -p ${out_base}/${ind[$i]}/
    ${map_script} ${star} ${reads_dir}/${ind[$i]}/ ${gen_dir} \
    ${out_base}/${ind[$i]}/ $map_gens

    mkdir -p ${out_base}/${ind[$i]}/pers/
    ln -s ${ln_dir}/${ind[$i]}/pers/Aligned.out.bam \
    ${out_base}/${ind[$i]}/pers/
done