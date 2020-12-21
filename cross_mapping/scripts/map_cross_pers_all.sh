#!/bin/bash

map_script=$1
star=$2
reads_dir=$3
gen_dir=$4
out_base=$5
ln_dir=$6
shift 6
inds=$@

for i in $inds; do
    map_gens=''
    for i2 in $inds; do
        [[ $i2 != $i ]] && map_gens="$map_gens $i2"
    done

    mkdir -p ${out_base}/${i}/
    ${map_script} ${star} ${reads_dir}/${i}/ ${gen_dir} \
    ${out_base}/${i}/ $map_gens

    mkdir -p ${out_base}/${i}/pers/
    ln -s ${ln_dir}/${i}/pers/Aligned.out.bam ${out_base}/${i}/pers/
done