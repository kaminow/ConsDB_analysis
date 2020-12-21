#!/bin/bash

split_script=$1
pers_vcf_dir=$2
out_dir=$3
py_script=$4
vcf_dir=$5
link_vcf_dir=$6
shift 6
inds=$@

for i in $inds; do
    split_vcfs=''
    for i2 in $inds; do
        [[ $i2 != $i ]] && \
        split_vcfs="$split_vcfs ${vcf_dir}/pers/${i2}/${i2}.vcf"
    done

    ${split_script} . . . ${pers_vcf_dir}/${i}/${i}.vcf . ${out_dir}/${i}/ \
    $py_script $split_vcfs
    ln -s ${link_vcf_dir}/${i}/pers/ ${out_dir}/${i}/pers
done