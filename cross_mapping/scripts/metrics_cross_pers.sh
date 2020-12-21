#!/bin/bash

metrics_script=$1
out_dir=$2
in_pref=$3
out_pref=$4
shift 4
inds=$@

for i in $inds; do
    met_gens=''
    for i2 in $inds; do
        [[ $i2 != $i ]] && met_gens="$met_gens $i2"
    done

    mkdir -p ${out_dir}/${i}/
    ${metrics_script} ${out_dir}/${i}/ $in_pref $out_pref $met_gens && echo $i
done