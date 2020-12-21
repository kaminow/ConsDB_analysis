#!/bin/bash

ind=$1
sup=$2
pop=$3
pers_vcf=$4
vcf_dir=$5
out_dir=$6
py_script=$7
shift 7
genomes=$@

if [[ $genomes == '' ]]; then
    genomes="${vcf_dir}/pers/${ind}/${ind}.vcf ${vcf_dir}/pan/pan.vcf
    ${vcf_dir}/SUP/${sup}/${sup}.vcf ${vcf_dir}/POP/${pop}/${pop}.vcf"
fi

for g in $genomes; do
    out=${out_dir}/$(basename $(dirname $g))

    mkdir -p $out

    /usr/bin/time -v python $py_script -pers_full $pers_vcf -gen $g -o $out && \
    echo $g &
done
wait
