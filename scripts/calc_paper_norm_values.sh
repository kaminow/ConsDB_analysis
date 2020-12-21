#!/bin/bash

map_dir=$1
shift 1
individs=$@

out_fn=${map_dir}/paper_fig_norms.csv
rm -f $out_fn

for i in $individs; do
    tot=$(grep -F 'Number of input reads' ${map_dir}/${i}/pers/Log.final.out \
    | awk '{print $NF}')
    hom=$(cat ${map_dir}/${i}/pers/pers_*_hom.hh_overlap | sort -n | uniq | \
    wc -l)
    echo ${i},${tot},${hom} >> $out_fn
done