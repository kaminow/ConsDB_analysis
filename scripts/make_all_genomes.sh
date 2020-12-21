#!/bin/bash

star=$1
ref_fa=$2
ref_gtf=$3
gen_dir=$4
shift 4
vcfs=$@

## Make the reference genome
out_dir=${gen_dir}/ref/
${star} --runMode genomeGenerate --runThreadN 40 --genomeFastaFiles $ref_fa \
--sjdbGTFfile $ref_gtf --genomeDir $out_dir --outFileNamePrefix $out_dir && \
echo ref

star_base="--runMode genomeGenerate --runThreadN 40 --genomeFastaFiles $ref_fa
--genomeTransformType Haploid --sjdbGTFfile $ref_gtf"

## Make all the other genomes
for fn in ${vcfs}; do
    pop=$(basename $fn)
    pop=${pop%.vcf*}
    out_dir=${gen_dir}/${pop}/
    mkdir -p $out_dir

    star_args="$star_base --genomeDir $out_dir --genomeTransformVCF $fn "
    star_args="$star_args --outFileNamePrefix $out_dir"
    $star $star_args && echo $pop
    # link ref genome if necessary
    [[ -d ${out_dir}/normalGenome ]] && rmdir ${out_dir}/normalGenome
    ln -s ${gen_dir}/ref/ ${out_dir}/normalGenome
done