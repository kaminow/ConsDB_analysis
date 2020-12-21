#!/bin/bash

comp_script=$1
out_dir=$2
awk_script=$3
frag_dir=$4
shift 4
inds=$@

for i in $inds; do
    comp_gens='pers'
    for i2 in $inds; do
        [[ $i2 != $i ]] && comp_gens="$comp_gens $i2"
    done

    out=${out_dir}/${i}/
    mkdir -p $out
    ${comp_script} ${out} ${awk_script} ${frag_dir} $comp_gens && echo $i
done