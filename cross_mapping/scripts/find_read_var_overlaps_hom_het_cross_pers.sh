#!/bin/bash

ov_script=$1
vt_dir=$2
out_dir=$3
shift 3
inds=$@

for i in $inds; do
    ov_gens='pers'
    for i2 in $inds; do
        [[ $i2 != $i ]] && ov_gens="$ov_gens $i2"
    done

    ${ov_script} ${vt_dir}/${i}/ ${out_dir} $i $ov_gens && echo $i
done