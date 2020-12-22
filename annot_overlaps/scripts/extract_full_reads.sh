#!/bin/bash

in_dir=$1
out_dir=$2
awk_script=$3
in_suf=$4
out_suf=$5
# reads_fn=$4

for ind in ${in_dir}/*/; do
    out_ind=${out_dir}/$(basename $ind)/
    mkdir -p $out_ind
    for gen in ${ind}/*/; do
        echo $(basename $gen)
        out_gen=${out_ind}/$(basename $gen)/
        mkdir -p $out_gen
        bam=${gen}/Aligned.out.bam
        for reads_fn in ${gen}/*.${in_suf}; do
            [[ ! -f $reads_fn ]] && continue
            out_fn=${out_gen}/$(basename ${reads_fn%.${in_suf}}).${out_suf}
            samtools view -H $bam > ${out_fn}_tmp
            awk -v reads_fn=$reads_fn -f $awk_script \
            <(samtools view $bam) >> ${out_fn}_tmp && \
            samtools view -b -o $out_fn ${out_fn}_tmp && rm ${out_fn}_tmp && \
            echo $reads_fn &
        done
        wait
    done
done

