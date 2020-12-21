#!/bin/bash

star=$1
ind=$2
id_tab=$3
reads_dir=$4
gen_dir=$5
out_dir=$6
shift 6
run_gens=$*

if [[ $run_gens == '' ]]; then
    run_gens='pers ref pan SUP POP'
fi

echo Running mapping for genomes: $run_gens

star_base="--readFilesCommand zcat --outSAMreadID Number --quantMode GeneCounts
--readFilesIn ${reads_dir}/${ind}/* --runThreadN 8 --outSAMtype BAM Unsorted"
pop_labs=('SUP' 'POP')

IFS=',' read -ra ind_info <<< $(grep "^${ind}" $id_tab)
if [[ ${#ind_info[@]} -eq 0 ]]; then
    echo "Individual ${ind} not found in table."
    exit 1
fi
ind_info=(${ind_info[1]} "${ind_info[1]}_${ind_info[2]}")

if [[ $run_gens == *'pers'* ]]; then
    ## Map to pers
    mkdir -p ${out_dir}/pers/
    star_args="${star_base} --genomeDir ${gen_dir}/${ind}/ 
    --outFileNamePrefix ${out_dir}/pers/"
    $star $star_args &> ${out_dir}/pers/out &
    # echo $star_args
fi


if [[ $run_gens == *'ref'* ]]; then
    ## Map to reference
    mkdir -p ${out_dir}/ref/
    star_args="${star_base} --genomeDir ${gen_dir}/ref/ 
    --outFileNamePrefix ${out_dir}/ref/"
    $star $star_args &> ${out_dir}/ref/out &
    # echo $star_args
fi

if [[ $run_gens == *'pan'* ]]; then
    ## Map to pan
    mkdir -p ${out_dir}/pan/
    star_args="${star_base} --genomeDir ${gen_dir}/pan/ 
    --outFileNamePrefix ${out_dir}/pan/"
    $star $star_args &> ${out_dir}/pan/out &
    # echo $star_args
fi

for i in {0..1}; do
    if [[ $run_gens == *"${pop_labs[$i]}"* ]]; then
        mkdir -p ${out_dir}/${pop_labs[$i]}/
        star_args="${star_base} --genomeDir ${gen_dir}/${ind_info[$i]}/ 
        --outFileNamePrefix ${out_dir}/${pop_labs[$i]}/"
        $star $star_args &> ${out_dir}/${pop_labs[$i]}/out &
        # echo $star_args
    fi
done
wait