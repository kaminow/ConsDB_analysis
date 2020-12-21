#!/bin/bash

map_dir=$1
in_pref=$2
out_pref=$3
shift 3
genomes=$@

if [[ $genomes == '' ]]; then
    genomes='ref pan SUP POP'
fi

for d in $genomes; do
    in_fn=${map_dir}/${d}/${in_pref}${d}
    out_fn=${map_dir}/${d}/${out_pref}${d}
    [[ ! -f $in_fn ]] && continue

    sum_files="${sum_files} ${out_fn}"
    echo Unique,Multiple,$(awk '$1==1 && $2>1' $in_fn | wc -l) > $out_fn
    echo Multiple,Unique,$(awk '$1>1 && $2==1' $in_fn | wc -l) >> $out_fn
    echo Mapped,Unmapped,$(awk '$1>0 && $2==0' $in_fn | wc -l) >> $out_fn
    echo Unmapped,Mapped,$(awk '$1==0 && $2>0' $in_fn | wc -l) >> $out_fn
    echo Unique,Unique,$(awk '$1==1 && $2==1' $in_fn | wc -l) >> $out_fn
    echo Unique,DiffEnds,$(awk '$1==1 && $2==1 && ($3!=$4 || $5-$6>50 \
        || $6-$5>50 || $7-$8>50 || $8-$7>50)' $in_fn | wc -l) >> $out_fn
done

out_fn=${map_dir}/${out_pref}$(basename $map_dir)
echo 'Pers_State,Query_State,Reference,Pan,SUP,POP' > $out_fn
paste -d, $sum_files | awk -F, 'BEGIN {OFS=","} {print $1,$2,$3,$6,$9,$12}' \
>> $out_fn
