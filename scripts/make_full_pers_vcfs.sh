#!/bin/bash

individ=$1
id_table=$2
vcf_out_dir=$3
awk_script=$4

individ_dir=$(grep -F $individ $id_table | cut -d, -f 4)
mkdir -p ${vcf_out_dir}/${individ}

for fn in ${individ_dir}/ALL.chr*.vcf.gz; do
    c=$(grep -oP 'chr.*?(?=\.)' <<< $fn)
    echo $c
    fn_out=${vcf_out_dir}/${individ}/${c}.vcf
    zcat $fn | awk -v samp=${individ} -f $awk_script | \
    sed -r 's/^([^#])/chr\1/' > $fn_out &
done
wait

fn_out=${vcf_out_dir}/${individ}/${individ}.vcf
cp ${vcf_out_dir}/${individ}/chr1.vcf $fn_out
for c in {2..22} X; do
    grep -v '^#' ${vcf_out_dir}/${individ}/chr${c}.vcf >> $fn_out
done

rm ${vcf_out_dir}/${individ}/chr*.vcf