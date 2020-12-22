#!/bin/bash

split_script=$1
pers_vcf_dir=$2
out_dir=$3
py_script=$4
vcf_dir=$5
id_tab=$6
link_vcf_dir=$7

ind=($(cut -d, -f 1 $id_tab))
sup=($(cut -d, -f 2 $id_tab))
pop=($(cut -d, -f 2-3 $id_tab | sed 's/,/_/'))

all_sups=$(sed 's/ /\n/g' <<< ${sup[@]} | sort | uniq)
all_pops=$(sed 's/ /\n/g' <<< ${pop[@]} | sort | uniq)

for i in $(seq 0 $((${#ind[@]} - 1))); do
    split_vcfs=''
    for g in ${all_sups[@]}; do
        if [[ $g != ${sup[$i]} ]]; then
            new_fn=${vcf_dir}/SUP/${g}/${g}.vcf
            split_vcfs="$split_vcfs $new_fn"
        fi
    done

    for g in ${all_pops[@]}; do
        if [[ $g != ${pop[$i]} ]]; then
            new_fn=${vcf_dir}/POP/${g}/${g}.vcf
            split_vcfs="$split_vcfs $new_fn"
        fi
    done

    ${split_script} . . . ${pers_vcf_dir}/${ind[$i]}/${ind[$i]}.vcf . \
    ${out_dir}/${ind[$i]}/ $py_script $split_vcfs
    ln -s ${link_vcf_dir}/${ind[$i]}/pers/ ${out_dir}/${ind[$i]}/pers
done