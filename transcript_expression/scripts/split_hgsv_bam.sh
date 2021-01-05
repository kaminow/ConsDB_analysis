#!/bin/bash

in_bam=$1
out_dir=$2
py_script=$3

in_dir=$(dirname $in_bam)

samtools view -h $in_bam | python $py_script ${in_dir}/split{}.sam && \
echo 'done splitting' && \
mkdir -p ${out_dir}/Rep1 && mkdir -p ${out_dir}/Rep2 && \
samtools view -b -@ 32 -o ${out_dir}/Rep1/Aligned.toTranscriptome.out.bam \
${in_dir}/split0.sam && rm ${in_dir}/split0.sam && echo '1 done' && \
samtools view -b -@ 32 -o ${out_dir}/Rep2/Aligned.toTranscriptome.out.bam \
${in_dir}/split1.sam && rm ${in_dir}/split1.sam && echo '2 done'
