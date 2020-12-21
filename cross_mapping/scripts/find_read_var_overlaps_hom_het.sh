#!/bin/bash

comp_vcf_dir=$1
mapping_dir=$2
individ=$3
shift 3
run_gens=$*

if [[ $run_gens == '' ]]; then
    run_gens='pers ref pan SUP POP'
fi

echo $individ $run_gens

vcf_fns=${comp_vcf_dir}/*/*.vcf
for gen in $run_gens; do
    in_fn=${mapping_dir}/${individ}/${gen}/Aligned.out.bam
    [[ ! -f $in_fn ]] && continue
    for vcf in $vcf_fns; do
        d=$(basename $(dirname $vcf))
        out_fn=${vcf%.vcf}
        out_fn=${mapping_dir}/${individ}/${gen}/${d}_$(basename $out_fn).hh_overlap
        mkdir -p $(dirname $out_fn)
        bedtools intersect -split -wa -a $in_fn -b $vcf | samtools view | \
        cut -f 1 > $out_fn && echo $gen &
    done
    wait
done