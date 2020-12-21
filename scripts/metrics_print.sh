#!/bin/bash

map_dir=$1
in_pref=$2
out_suf=$3
# out_dir=$3
shift 3
run_gens=$*

if [[ $run_gens == '' ]]; then
    run_gens='pers ref pan SUP POP'
fi

for d in $run_gens; do
    in_fn=${map_dir}/${d}/${in_pref}${d}
    out_pref=${map_dir}/${d}/${d}_
    [[ ! -f $in_fn ]] && continue

    fns=(${out_pref}Unique_Multiple.${out_suf} \
        ${out_pref}Multiple_Unique.${out_suf} \
        ${out_pref}Mapped_Unmapped.${out_suf} \
        ${out_pref}Unmapped_Mapped.${out_suf} \
        ${out_pref}DiffEnds.${out_suf})

    awk '{if ($1==1 && $2>1) {print $NF}}' $in_fn > ${fns[0]} &
    awk '{if ($1>1 && $2==1) {print $NF}}' $in_fn > ${fns[1]} &
    awk '{if ($1>0 && $2==0) {print $NF}}' $in_fn > ${fns[2]} &
    awk '{if ($1==0 && $2>0) {print $NF}}' $in_fn > ${fns[3]} &
    awk '{if ($1==1 && $2==1 && ($3!=$4 || $5-$6>50 \
        || $6-$5>50 || $7-$8>50 || $8-$7>50)) {print $NF}}' $in_fn > ${fns[4]} &
done
wait