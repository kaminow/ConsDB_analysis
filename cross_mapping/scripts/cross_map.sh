#!/bin/bash

star=$1
reads_dir=$2
gen_dir=$3
out_dir=$4
shift 4
gens=($@)
n_gens=${#gens[@]}

star_base="--readFilesCommand zcat --outSAMreadID Number --quantMode GeneCounts
--readFilesIn ${reads_dir}/* --runThreadN 3 --outSAMtype BAM Unsorted"

n_simul=5
completed=0
while [[ $completed -lt $n_gens ]]; do
    n_left=$(expr $n_gens - $completed)
    if [[ $n_left -lt $n_simul ]]; then
        n_to_add=$n_left
    else
        n_to_add=$n_simul
    fi
    
    for i in $(seq $completed $(($n_to_add + $completed - 1))); do
        g=${gens[$i]}
        out_tmp=${out_dir}/${g}/
        mkdir -p $out_tmp
        star_args="${star_base} --genomeDir ${gen_dir}/${g}/
        --outFileNamePrefix ${out_tmp}/"
        $star $star_args &> ${out_tmp}/out && echo ${g} done &
    done
    wait
    completed=$(expr $completed + $n_to_add)
done
