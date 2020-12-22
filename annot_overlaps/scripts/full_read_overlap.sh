#!/bin/bash

reads_dir=$1
vcf_dir=$2
out_dir=$3
in_suf=$4
out_suf=$5

for ind in ${reads_dir}/*/; do
    out_ind=${out_dir}/$(basename $ind)/
    mkdir -p $out_ind
    for gen in ${ind}/*/; do
        echo $(basename $gen)
        out_gen=${out_ind}/$(basename $gen)/
        mkdir -p $out_gen
        # for reads_fn in ${gen}/*.${in_suf}; do
        #     et=$(basename ${reads_fn%.${in_suf}}
        vcf_tmp=${vcf_dir}/$(basename $ind)/$(basename $gen)/
        for vcf in ${vcf_tmp}/gtf_vcfs/*.vcf; do
            [[ $(basename -a ${gen}/*.${in_suf}) == '*.full_reads' ]] && break
            # chr=$(cut -d. -f 2 <<< $(basename $vcf))
            # out_fn=${out_gen}/${chr}.${out_suf}
            out_fn=${out_gen}/$(basename ${vcf%.vcf}).${out_suf}

            # bedtools intersect -a <(zcat $vcf | sed 's/^[^#]/chr&/' | \
            bedtools intersect -a $vcf -b ${gen}/*.${in_suf} -C -filenames \
            -split > $out_fn && echo $gen $chr &
        done
        wait
    done
done
