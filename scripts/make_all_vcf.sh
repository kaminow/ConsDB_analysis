#!/bin/bash

id_table=$1
db_dir=$2
vcf_out_dir=$3
consdb=$4
consdb_dir=$5

samps=($(cut -d, -f 1 $id_table))
sup=$(cut -d, -f 2 $id_table | sort | uniq)
pop=$(cut -d, -f 2-3 $id_table | sed 's/,/_/g' | sort | uniq)
individ_dirs=($(cut -d, -f 4 $id_table))

## Make personal VCF files
for i in $(seq 0 $((${#samps[@]} - 1))); do
    s=${samps[$i]}
    out_dir=${vcf_out_dir}/pers/${s}/
    mkdir -p $out_dir

    echo $s
    for fn in ${individ_dirs[$i]}/ALL.chr*.vcf.gz; do
        # [[ ! "${fn}" =~ ALL\.chr[0-9XYM] ]] && continue
        c=${fn##*ALL.}
        c=${c%.shape*}
        fn_out=${out_dir}/${c}.vcf
        python $consdb Filter -i $fn -o $fn_out -samp $s -quiet && echo $c &
    done
    wait
    
    # Join the individual VCF files
    mv ${out_dir}/chr1.vcf ${out_dir}/${s}.vcf
    for fn in ${out_dir}/chr*.vcf; do
        grep -v '^#' $fn >> ${out_dir}/${s}.vcf && rm $fn
    done
    sed -i -E 's/^([^#])/chr\1/' ${out_dir}/${s}.vcf
done

## Make super-population VCFs
for p in $sup; do
    out_dir=${vcf_out_dir}/SUP/${p}/
    mkdir -p $out_dir

    python $consdb Cons -i $consdb_dir -o $out_dir -pop $p \
    -join ${out_dir}/${p}.vcf -clean -mp -mp_proc 40 && echo $p
    sed -i -E 's/^([^#])/chr\1/' ${out_dir}/${p}.vcf
done

## Make population VCFs
for p in $pop; do
    out_dir=${vcf_out_dir}/POP/${p}/
    mkdir -p $out_dir

    python $consdb Cons -i $consdb_dir -o $out_dir -pop $p \
    -join ${out_dir}/${p}.vcf -clean -mp -mp_proc 40 && echo $p
    sed -i -E 's/^([^#])/chr\1/' ${out_dir}/${p}.vcf
done

## Make pan VCF
out_dir=${vcf_out_dir}/pan/
mkdir -p $out_dir

python $consdb Cons -i $consdb_dir -o $out_dir -join ${out_dir}/pan.vcf \
-clean -mp -mp_proc 40 && echo pan
sed -i -E 's/^([^#])/chr\1/' ${out_dir}/pan.vcf