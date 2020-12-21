#!/bin/bash

reads_suf=$2
out_suf=$3
ov_suf=$4

if [[ $ov_suf == '' ]]; then
    ov_suf='overlap'
fi

for d in ${1}/*/; do
    gen=$(basename $d)
    for fn in ${d}/${gen}_*.${reads_suf}; do
        [[ ! -f $fn || $(basename $d) == 'pers' ]] && continue
        search_fns="${d}/pers_*.${ov_suf} ${1}/pers/pers_*.${ov_suf}"
        if [[ $(basename $d) != 'ref' || \
            -f  $(ls ${d}/ref_*.${ov_suf} | head -n 1) ]]; then
            new_fns=$(ls ${d}/${gen}_*.${ov_suf} | grep -v "${gen}_[A-Z]")
            search_fns="$search_fns $new_fns"
        fi

        grep -Fx -f $fn $search_fns > ${fn%.${reads_suf}}.${out_suf} &
    done
done
wait