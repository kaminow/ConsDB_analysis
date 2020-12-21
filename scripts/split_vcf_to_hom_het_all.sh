#!/bin/bash
id_tab=$1
pers_dir=$2
vcf_dir=$3
out_dir=$4
bash_script=$5
py_script=$6
shift 6
individ=$@

if [[ $individ == '' ]]; then
    ind=($(cut -d, -f 1 $id_tab))
    sup=($(cut -d, -f 2 $id_tab))
    pop=($(cut -d, -f 2-3 $id_tab | sed 's/,/_/'))
else
    ind=()
    sup=()
    pop=()
    for i in $individ; do
        inf=$(grep -F $i $id_tab) || { echo $i not found in table; continue; };
        ind+=($i)
        sup+=($(cut -d, -f 2 <<< $inf))
        pop+=($(cut -d, -f 2-3 <<< $inf | sed 's/,/_/'))
    done
fi

for i in $(seq 0 $((${#ind[@]} - 1))); do
    out_tmp=${out_dir}/${ind[$i]}/
    ${bash_script} ${ind[$i]} ${sup[$i]} ${pop[$i]} \
    ${pers_dir}/${ind[$i]}/${ind[$i]}.vcf $vcf_dir $out_tmp \
    $py_script
    ## Rename the folders to match with the downstream scripts
    mv ${out_tmp}/${sup[$i]} ${out_tmp}/SUP
    mv ${out_tmp}/${pop[$i]} ${out_tmp}/POP
    mv ${out_tmp}/${ind[$i]} ${out_tmp}/pers
done