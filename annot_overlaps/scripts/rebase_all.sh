#!/bin/bash

scripts_dir=$1
in_dir=$2
out_dir=$3
shift 3
individuals=$@

for ind in $individuals; do
    for h in het hom; do
        for g in ref pan SUP POP; do
            mkdir -p ${out_dir}/${ind}/${g}
        done
        time -p python ${scripts_dir}/rebase_vcf.py \
        -pers ${in_dir}/${ind}/pers/all_${h}.vcf \
        -i ${in_dir}/${ind}/pan/all_${h}.vcf \
        ${in_dir}/${ind}/SUP/all_${h}.vcf \
        ${in_dir}/${ind}/POP/all_${h}.vcf \
        -ref -o ${out_dir}/${ind}/ && echo ${ind}_${h} &
    done
    wait
done
