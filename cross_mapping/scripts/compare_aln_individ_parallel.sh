#!/bin/bash

map_dir=$1
awk_script=$2
frag_pref=$3
shift 3
run_gens=$*

if [[ $run_gens == '' ]]; then
    run_gens='pers ref pan SUP POP'
fi
[[ $run_gens != *'pers'* ]] && run_gens="pers ${run_gens}"

echo $run_gens

lines_per_file=1500000

echo extract start: $(date)
# Extract from BAM format
for gen in $run_gens; do
    fn=${map_dir}/${gen}/Aligned.out.bam
    [[ ! -f $fn ]] && continue
    samtools view -o $(dirname $fn)/Aligned.out.sam $fn &
done
wait

# Fragment files
n_max=0
for gen in $run_gens; do
    fn=${map_dir}/${gen}/Aligned.out.sam
    [[ ! -f $fn ]] && continue

    n=$(tail -n 1 $fn | cut -f 1)
    [[ $n -gt $n_max ]] && n_max=$n
done
echo $n_max

echo frag start: $(date)
for gen in $run_gens; do
    fn=${map_dir}/${gen}/Aligned.out.sam
    [[ ! -f $fn ]] && continue

    echo $(basename $(dirname $fn))
    n_files=0
    n_cur=0
    while [[ $(($n_files * $lines_per_file)) -lt $n_max ]]; do
        if [[ $n_cur -ge 30 ]]; then
            wait
            n_cur=0
        fi
        n_files=$(($n_files + 1))
        frag_fn=${frag_pref}${n_files}_${gen}
        awk -v min_cut=$((n_files * $lines_per_file - $lines_per_file)) \
        -v max_cut=$((n_files * $lines_per_file)) \
        '$1 > min_cut && $1 <= max_cut' $fn > $frag_fn &
        n_cur=$(($n_cur + 1))
        # If SAM files are sorted, can exit once read ids are too big
        # '{(if $1 <= cutoff) {print} else {exit}}' $fn > $frag_fn &
    done
    wait
    echo finished ${fn}: $(date)
    echo '-----'
done
echo '#####'

echo comp start: $(date)
for gen in $run_gens; do
    [[ ! -d ${map_dir}/${gen}/ || $gen == 'pers' ]] && continue
    echo $gen
    n_cur=0
    for i in $(seq 1 $n_files); do
        if [[ $n_cur -ge 30 ]]; then
            wait
            n_cur=0
        fi
        awk -f ${awk_script} ${frag_pref}${i}_pers ${frag_pref}${i}_${gen} \
        > ${frag_pref}comp_${i}_${gen} &
        n_cur=$(($n_cur + 1))
    done
    wait
    echo join start: $(date)
    for i in $(seq 1 $n_files); do
    	if [[ $i -eq 1 ]]; then
	        cat ${frag_pref}comp_${i}_${gen} > ${frag_pref}comp_${gen}
	    else
	    	# Skip the header line if not the first file
	    	tail -n +2 ${frag_pref}comp_${i}_${gen} >> ${frag_pref}comp_${gen}
        fi
    done
    mv ${frag_pref}comp_${gen} ${map_dir}/${gen}/all_reads_aln_comp_${gen}
    echo '-----'
done

rm ${map_dir}/*/Aligned.out.sam
if [[ -d $frag_pref ]]; then
    rm ${frag_pref}/*
else
    rm ${frag_pref}*
fi
